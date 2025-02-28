const float ENDSCREEN_X_LIMIT = 1650;
const float ENDSCREEN_Y_LIMIT = 500;
const float ENDSCREEN_Z_LIMIT = -10;
const float WAIT_TARGET_DEAD_TIME = 1.5;
const float DAMAGE_DELAY = 0.5;
const float DEAD_FALL_SPEED = 80;
const float THROWING_FLY_TIME = 0.6;
const float MAX_COIN_VALUE = 15;
const float RANGE_COLLIDER_SIZE = 30;

enum EAttackType
{
	Punch,
	Melee,
	MeleeAndShield,
	GunAndShield,
	Pistol,
	Gun,
	DualWieldMelee,
	DualWieldGun,
	Staff,
}

class AZombie : AHumanlite
{
	// UPROPERTY(RootComponent, DefaultComponent)
	// UCapsuleComponent Collider;
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;

	UPROPERTY(DefaultComponent)
	UBoxComponent RangeCollider;

	UPROPERTY(DefaultComponent, Attach = BodyMesh, AttachSocket = RightHand)
	UStaticMeshComponent RightHandWp;

	UPROPERTY(DefaultComponent, Attach = BodyMesh, AttachSocket = LeftHand)
	UStaticMeshComponent LeftHandWp;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> WeaponList;

	default TargetResponseComponent.TargetType = ETargetType::Zombie;

	UPROPERTY(DefaultComponent)
	UPhaseResponseComponent PhaseResponseComponent;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem SmackVFX;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage DamageAnim;

	TArray<UAnimMontage> AttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent HitSFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent DeadSFX;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem DeadVFX;

	float CoinValue = 0;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieStatusTable;

	UPROPERTY(Category = Drop)
	TSubclassOf<ACoin> CoinTemplate;

	UZombieAnimInst AnimateInst;
	FNameEvent EOnZombDie;
	FFloatNameDelegate DOnZombieReach;

	float delayMove = 2.f;
	bool bIsAttacking = false;

	private UDamageResponseComponent Target; // Or maybe allow multiple target here? would that be easier?

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default MovementComp.bShouldBounce = true;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.bConstrainToPlane = true;
	default MovementComp.PlaneConstraintAxisSetting = EPlaneConstraintAxisSetting::UseGlobalPhysicsSetting;
	default MovementComp.PlaneConstraintNormal = FVector(0, 0, 1);
	default MovementComp.AutoActivate = false;
	default MovementComp.Bounciness = 0.8;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();

		AnimateInst = Cast<UZombieAnimInst>(BodyMesh.GetAnimInstance());
		// Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");

		AbilitySystem.EOnPostSetCurrentValue.AddUFunction(this, n"OnPostSetCurrentValue");
		AbilitySystem.EOnPostCalculation.AddUFunction(this, n"OnPostCalculation");

		DamageResponseComponent.Initialize(AbilitySystem);
		DamageResponseComponent.EOnHitCue.AddUFunction(this, n"TakeHitCue");
		DamageResponseComponent.EOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.EOnHealCue.AddUFunction(this, n"HealCue");
		DamageResponseComponent.EOnDeadCue.AddUFunction(this, n"DeadCue");

		StatusResponseComponent.Initialize(AbilitySystem);
		StatusResponseComponent.DChangeOverlayColor.BindUFunction(ColorOverlay, n"ChangeOverlayColor");

		AttackResponseComponent.Initialize(AbilitySystem);
		AttackResponseComponent.SetupAttack(n"StartAttacking");
		AttackResponseComponent.EOnAnimHitNotify.AddUFunction(this, n"OnAttackHitNotify");
		AttackResponseComponent.EOnAnimEndNotify.AddUFunction(this, n"OnAttackEndNotify");

		MovementResponseComponent.Initialize(AbilitySystem);
		MovementResponseComponent.EOnBounceCue.AddUFunction(this, n"OnBounceCue");
		MovementResponseComponent.EOnPreAddForceCue.AddUFunction(this, n"OnPreAddForceCue");
		// Temporary
		MovementResponseComponent.StopLifeTime = 0;

		TargetResponseComponent.Initialize(AbilitySystem);
		PhaseResponseComponent.Initialize(AbilitySystem);
	}

	UFUNCTION()
	void SetData(FZombieDT DataRow)
	{
		TMap<FName, float32> Data;
		Data.Add(PrimaryAttrSet::MaxHP, DataRow.HP);
		Data.Add(AttackAttrSet::Attack, DataRow.Atk);
		Data.Add(AttackAttrSet::AttackCooldown, DataRow.AttackCooldown);
		Data.Add(AttackAttrSet::AttackRange, DataRow.AttackRange);
		Data.Add(MovementAttrSet::MoveSpeed, DataRow.Speed);
		Data.Add(MovementAttrSet::Accel, DataRow.Accel);
		Data.Add(MovementAttrSet::Bounciness, DataRow.Bounciness);

		PhaseResponseComponent.SetupPhaseData(DataRow.NumberOfPhases,
											  DataRow.Lv1Modifiers,
											  DataRow.Lv2Modifiers,
											  DataRow.Lv3Modifiers);

		AbilitySystem.ImportData(Data);

		SetMoveSpeed(DataRow.Speed);
		delayMove /= AnimateInst.AnimPlayRate;
		System::SetTimer(this, n"EmergeDone", delayMove, false);
		System::SetTimer(this, n"InitMovement", delayMove, false);

		SetBodyScale(DataRow.BodyScale);
		SetHeadScale(DataRow.HeadScale);
		ChangeAttackType(DataRow.AttackType, DataRow.ProjectileTemplate);
		if (!IsMelee())
		{
			RangeCollider.SetBoxExtent(FVector(8 * DataRow.WeaponScale.X,
											   DataRow.AttackRange,
											   RANGE_COLLIDER_SIZE));
		}
		if (DataRow.AttackType == EAttackType::Staff)
		{
			System::SetTimer(this, n"PeriodicCheck", DataRow.AttackCooldown, true);
		}
		CoinValue = DataRow.CoinDropAmount;
	}

	UFUNCTION()
	private void OnPostSetCurrentValue(FName AttrName, float Value)
	{
		if (AttrName == MovementAttrSet::MoveSpeed)
		{
			SetMoveSpeed(Value);
		}
		if (AttrName == AttackAttrSet::AttackCooldown)
		{
			SetAttackCooldown(Value);
		}
	}

	UFUNCTION()
	private void OnPostCalculation(FName AttrName, float Value)
	{
		if ((AttrName == PrimaryAttrSet::Damage || AttrName == PrimaryAttrSet::HP) && Value > 0)
		{
			float HPPercentage = AbilitySystem.GetValue(PrimaryAttrSet::HP) / AbilitySystem.GetValue(PrimaryAttrSet::MaxHP);
			PhaseResponseComponent.CheckForRankUp(HPPercentage);
			HPBarWidget.SetHPBar(HPPercentage);
		}
		if (AttrName == AttackAttrSet::AttackCooldown && Value > 0)
		{
			System::ClearTimer(this, "PeriodicCheck");
			System::SetTimer(this, n"PeriodicCheck", Value, true);
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		delayMove -= DeltaSeconds;
		if (delayMove <= 0)
		{

			FVector loc = GetActorLocation();
			if (DamageResponseComponent.bIsDead)
			{
				// Fall down animation should run at constant speed
				loc.Z -= DEAD_FALL_SPEED * DeltaSeconds;
				SetActorLocation(loc);
			}
			else if (AnimateInst.AnimMoveSpeed == 0 && !bIsAttacking)
			{
				if (IsValid(Target))
				{
					AttackResponseComponent.ActivateAttack();
				}
				else
				{
					// Start Attacking was called if there is a new target
					if (!CheckForNewTarget())
					{
						StopAttacking();
						RemoveTarget();
						RestartMove();
					}
				}
			}

			if (loc.Z <= ENDSCREEN_Z_LIMIT
				|| loc.X > ENDSCREEN_X_LIMIT
				|| loc.Y > ENDSCREEN_Y_LIMIT
				|| loc.Y < -ENDSCREEN_Y_LIMIT)
			{
				if (!DamageResponseComponent.bIsDead) // If not dead, meaning the zomb goes to end screen, Deal dmg to player
				{
					DOnZombieReach.ExecuteIfBound(AbilitySystem.GetValue(AttackAttrSet::Attack), GetName());
				}
				DestroyActor();
			}
		}
		else if (AnimateInst.AnimMoveSpeed > 0)
		{
			AnimateInst.SetMoveSpeed(0);
		}
	}

	void ChangeAttackType(EAttackType iAtkType, TSubclassOf<AActor> iProjectileTemplate = nullptr)
	{
		AnimateInst.AtkType = iAtkType;
		if (!IsMelee())
		{
			auto RangeAttackComp = URangeAttackComponent::GetOrCreate(this);
			RangeAttackComp.Initialize(AbilitySystem);
			RangeAttackComp.SetProjectileTemplate(iProjectileTemplate);
			RangeCollider.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		}
		else
		{
			RangeCollider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		}
	}

	void SetWeapon(UStaticMesh MainHand, UStaticMesh OffHand, EAttackType iAtkType, TArray<UAnimMontage> AtkAnims)
	{
		ChangeAttackType(iAtkType);

		AnimateInst.bIsMirror = Math::RandBool();
		RangeCollider.SetRelativeLocation(FVector(AnimateInst.bIsMirror ? RANGE_COLLIDER_SIZE : -RANGE_COLLIDER_SIZE,
												  AbilitySystem.GetValue(AttackAttrSet::AttackRange),
												  0));
		ReplaceAnimation(AtkAnims);

		if (iAtkType == EAttackType::Punch)
		{
			return;
		}

		GetMainHand().StaticMesh = MainHand;
		GetOffHand().StaticMesh = OffHand;
		FString MainSocket = AnimateInst.IsMirroredHand() ? "Left" : "Right";
		FString OffSocket = AnimateInst.IsMirroredHand() ? "Right" : "Left";
		switch (iAtkType)
		{
			case EAttackType::Melee:
			case EAttackType::Staff:
			case EAttackType::DualWieldMelee:
			{
				MainSocket += "Hand";
				break;
			}
			case EAttackType::MeleeAndShield:
			{
				MainSocket += "Hand";
				OffSocket += "Shield";
				break;
			}
			case EAttackType::Gun:
			{
				MainSocket += "Gun";
				break;
			}
			case EAttackType::DualWieldGun:
			{
				MainSocket += "Gun";
				OffSocket += "Gun";
				break;
			}
			default:
			{
				Print("Attack type not coded yet");
				break;
			}
		}

		GetMainHand().AttachTo(BodyMesh, FName(MainSocket));
		GetOffHand().AttachTo(BodyMesh, FName(OffSocket));
	}

	void RemoveWeapon(bool bRemoveMainHand = true)
	{
		if (bRemoveMainHand)
		{
			GetMainHand().StaticMesh = nullptr;
		}
		else
		{
			GetOffHand().StaticMesh = nullptr;
		}
	}

	bool SetTarget(AActor iTarget)
	{
		Target = UDamageResponseComponent::Get(iTarget);
		if (IsValid(Target))
		{
			return true;
		}
		return false;
	}

	UStaticMeshComponent GetMainHand()
	{
		return AnimateInst.IsMirroredHand() ? LeftHandWp : RightHandWp;
	}

	UStaticMeshComponent GetOffHand()
	{
		return AnimateInst.IsMirroredHand() ? RightHandWp : LeftHandWp;
	}

	// void ChangeColorOverlayTarget(UMaterialInstanceDynamic& MatInstance, bool bIsMainHand = true)
	// {
	// 	if (bIsMainHand == AnimateInst.bIsMirror)
	// 	{
	// 		MatInstance = Material::CreateDynamicMaterialInstance(LeftHandWp.GetMaterial(0));
	// 		LeftHandWp.SetMaterial(0, MatInstance);
	// 	}
	// 	else
	// 	{
	// 		MatInstance = Material::CreateDynamicMaterialInstance(RightHandWp.GetMaterial(0));
	// 		RightHandWp.SetMaterial(0, MatInstance);
	// 	}
	// }

	void ReplaceAnimation(TArray<UAnimMontage> NewAnim)
	{
		AttackAnim = NewAnim;
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		OverlapActor(OtherActor);
	}

	UFUNCTION()
	bool OverlapActor(AActor OtherActor)
	{
		if (TargetResponseComponent.IsTargetable(OtherActor, AnimateInst.AtkType == EAttackType::Staff))
		{
			Target = UDamageResponseComponent::Get(OtherActor);
			if (IsValid(Target) && !bIsAttacking)
			{
				if (AnimateInst.AtkType == EAttackType::Staff && !Target.IsDamaged())
				{
					RemoveTarget();
					return false;
				}
				if (AttackResponseComponent.ActivateAttack())
				{
					Target.EOnDeadCue.AddUFunction(this, n"StopAttacking");
					Target.EOnDeadCue.AddUFunction(this, n"RemoveTargetWhenDead");
					auto TargetMoveRes = UMovementResponseComponent::Get(OtherActor);
					if (IsValid(TargetMoveRes))
					{
						TargetMoveRes.EOnPostAddForce.AddUFunction(this, n"InterruptAttacking");
					}
					return true;
				}
			}
		}
		return false;
	}

	UFUNCTION()
	void InterruptAttacking()
	{
		if (IsValid(Target) && bIsAttacking)
		{
			// if (Target == UDamageResponseComponent::Get(OtherActor))
			// {
			StopAttacking();
			RemoveTarget();
			//}
		}
	}

	UFUNCTION()
	void StartAttacking()
	{
		if (bIsAttacking)
		{
			PrintWarning("Already attacking");
		}
		MovementComp.StopMovementImmediately();
		bIsAttacking = true;
		AnimateInst.OnMontageEnded.Clear();
		if (AttackAnim.Num() > 0)
		{
			SetActorRotation(FRotator::MakeFromX(Target.GetOwner().GetActorLocation()
												 - GetActorLocation())
							 + FRotator(0, -90, 0));
			int random = Math::RandRange(0, AttackAnim.Num() - 1);
			AnimateInst.Montage_Play(AttackAnim[random], AttackAnim[random].PlayLength / AbilitySystem.GetValue(AttackAttrSet::AttackCooldown));
		}
		else
		{
			PrintWarning("No attack anim");
		}
	}

	// Called when the animation trigger an event
	UFUNCTION()
	void OnAttackHitNotify()
	{
		if (IsValid(Target))
		{
			SetActorRotation(FRotator::MakeFromX(Target.GetOwner().GetActorLocation()
												 - GetActorLocation())
							 + FRotator(0, -90, 0));
			if (IsMelee())
			{
				Target.TakeHit(AbilitySystem.GetValue(AttackAttrSet::Attack));
			}
			else
			{
				if (AnimateInst.AtkType == EAttackType::Staff)
				{
					auto SceneComp = USceneComponent::Get(Target.GetOwner());
					URangeAttackComponent::Get(this).SpawnBullet(GetAttackLocation(), GetActorRotation(), SceneComp);
				}
				else
				{
					URangeAttackComponent::Get(this).SpawnBullet(GetAttackLocation(), GetActorRotation());
				}
			}
		}
	}

	UFUNCTION()
	private void OnAttackEndNotify()
	{
		if (!CheckForNewTarget())
		{
			StopAttacking();
			RemoveTarget();
			RestartMove();
		}
	}

	UFUNCTION()
	FVector GetAttackLocation()
	{
		FVector Result = GetMainHand().GetSocketLocation(n"Muzzle");
		return Result;
	}

	UFUNCTION()
	FRotator GetAttackRotation()
	{
		FRotator Result = BodyMesh.GetWorldRotation();
		Result.XRoll = 0;
		Result.YPitch = 0;
		return Result;
	}

	UFUNCTION()
	void StopAttacking()
	{
		if (bIsAttacking)
		{
			bIsAttacking = false;
			AnimateInst.Montage_Stop(DAMAGE_DELAY);
		}
	}

	UFUNCTION()
	void RemoveTargetWhenDead()
	{
		if (RemoveTarget())
		{
			delayMove = WAIT_TARGET_DEAD_TIME;
		}
	}

	UFUNCTION()
	bool RemoveTarget()
	{
		if (Target != nullptr)
		{
			Target.EOnDeadCue.UnbindObject(this);
			Target = nullptr;
			return true;
		}
		return false;
	}

	bool IsMelee()
	{
		return (AnimateInst.AtkType == EAttackType::Melee
				|| AnimateInst.AtkType == EAttackType::MeleeAndShield
				|| AnimateInst.AtkType == EAttackType::Punch
				|| AnimateInst.AtkType == EAttackType::DualWieldMelee);
	}

	UFUNCTION()
	void PeriodicCheck()
	{
		if (DamageResponseComponent.CheckIsAlive())
		{
			CheckForNewTarget();
		}
	}

	UFUNCTION()
	bool CheckForNewTarget()
	{
		TArray<AActor> OverlappingActors;
		if (CheckForTargetType(OverlappingActors, AObstacle))
		{
			return OverlapActor(OverlappingActors[0]);
		}
		else if (CheckForTargetType(OverlappingActors, ASurvivor))
		{
			return OverlapActor(OverlappingActors[0]);
		}
		return false;
	}

	bool CheckForTargetType(TArray<AActor>& OverlappingActors, TSubclassOf<AActor> ClassFilter)
	{
		if (IsMelee())
		{
			Collider.GetOverlappingActors(OverlappingActors, ClassFilter);
		}
		else if (AnimateInst.AtkType == EAttackType::Staff)
		{
			FindNearestTarget(OverlappingActors, EObjectTypeQuery::Enemy);
		}
		else
		{
			RangeCollider.GetOverlappingActors(OverlappingActors, ClassFilter);
		}
		return OverlappingActors.Num() > 0;
	}

	bool FindNearestTarget(TArray<AActor>& OverlappingActors, EObjectTypeQuery iTargetType)
	{
		TArray<EObjectTypeQuery> traceObjectTypes;
		traceObjectTypes.Add(iTargetType);
		TArray<AActor> ignoreActors;
		ignoreActors.Add(this);
		TArray<AActor> outActors;
		System::SphereOverlapActors(GetActorLocation(), AbilitySystem.GetValue(AttackAttrSet::AttackRange) * 2, traceObjectTypes, nullptr, ignoreActors, outActors);

		float32 Distance = -1;
		AActor NearestTarget = Gameplay::FindNearestActor(GetActorLocation(), outActors, Distance);
		if (IsValid(NearestTarget))
		{
			OverlappingActors.Add(NearestTarget);
			return true;
		}
		return false;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Visual Cues:

	UFUNCTION()
	void TakeHitCue()
	{
		Niagara::SpawnSystemAtLocation(SmackVFX, GetActorLocation());

		System::ClearTimer(this, "EmergeDone");
		EmergeDone();

		AnimateInst.Montage_Play(DamageAnim);
		FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
		MovementComp.StopMovementImmediately();
		delayMove = DAMAGE_DELAY;
		InterruptAttacking();
	}

	UFUNCTION()
	private void HealCue()
	{
		// Print("HealCue");
	}

	// void TakeDamageCue() override
	// {
	// 	Super::TakeDamageCue();
	// }

	void DeadCue() override
	{
		Super::DeadCue();
		StatusResponseComponent.DChangeOverlayColor.Clear();

		MovementComp.StopSimulating(FHitResult());
		EOnZombDie.Broadcast(GetName());

		Niagara::SpawnSystemAtLocation(DeadVFX, GetActorLocation() + FVector(0, 0, 220)); // TODO: Change this with HeadMesh Location, also need to consider the scale
		FMODBlueprint::PlayEventAtLocation(this, DeadSFX, GetActorTransform(), true);

		ACoin SpawnedActor = Cast<ACoin>(SpawnActor(CoinTemplate, GetActorLocation(), GetActorRotation()));
		SpawnedActor.ExpectValueToCoinType(CoinValue);
	}

	void PlayDeadAnim(int AnimIndex) override
	{
		AnimateInst.StopSlotAnimation();
		AnimateInst.Montage_Play(DeadAnims[AnimIndex], 1);
		delayMove = DeadAnims[AnimIndex].GetPlayLength();
	}

	void SetAttackCooldown(float Value)
	{
		if (IsValid(AnimateInst.CurrentActiveMontage) && !DamageResponseComponent.bIsDead)
		{
			AnimateInst.Montage_SetPlayRate(AnimateInst.CurrentActiveMontage, AnimateInst.CurrentActiveMontage.PlayLength / Value);
		}
	}

	void SetMoveSpeed(float iSpeed)
	{
		AnimateInst.SetMoveSpeed(iSpeed);
		MovementComp.MaxSpeed = iSpeed;
	}

	UFUNCTION()
	void RestartMove()
	{
		ResetRotation();
		MovementResponseComponent.SetIsAccelable(true);
		AnimateInst.SetMoveSpeed(AbilitySystem.GetValue(MovementAttrSet::MoveSpeed));
		MovementResponseComponent.InitForce(FVector(1, 0, 0), 1);
	}

	// Called when being bounced/added force by something else
	UFUNCTION()
	private void OnPreAddForceCue(FVector Value)
	{
		// MovementComp.StopMovementImmediately();
		MovementResponseComponent.SetIsAccelable(false);
	}

	// Called when bounced off something
	UFUNCTION()
	void OnBounceCue(const FHitResult Hit)
	{
		Gameplay::PlayWorldCameraShake(ShakeStyle, GetActorLocation(), 0, 10000, 0, false);
	}

	UFUNCTION(BlueprintCallable)
	void EmergeDone()
	{
		if (AnimateInst.bIsEmergeDone == false)
		{
			AnimateInst.bIsEmergeDone = true;
		}
	}

	UFUNCTION()
	void InitMovement()
	{
		delayMove = 0;
		SetActorTickEnabled(true);
		MovementResponseComponent.InitForce(FVector(1, 0, 0), 1);
	}

	void ThrowToGroundTween(float Length, bool bRandomizeY = false)
	{
		System::ClearTimer(this, "EmergeDone");
		System::ClearTimer(this, "InitMovement");

		FVector OriginalLoc = GetActorLocation();
		FRotator OriginalRot = GetActorRotation();
		FRotator TargetRot = FRotator(0, -90, 0);

		if (bRandomizeY)
		{
			FVector2D OriginalLocXY = FVector2D(OriginalLoc.X, OriginalLoc.Y);
			FVector2D TargetLocXY = FVector2D(OriginalLoc.X + Length, Math::RandRange(-400.0, 400.0));
			UFCTweenBPActionVector2D TweenLocXY = UFCTweenBPActionVector2D::TweenVector2D(OriginalLocXY, TargetLocXY, THROWING_FLY_TIME, EFCEase::Linear);
			TweenLocXY.ApplyEasing.AddUFunction(this, n"FlyingLocationXY");
			TweenLocXY.Start();
		}
		else
		{
			UFCTweenBPActionFloat TweenLocX = UFCTweenBPActionFloat::TweenFloat(OriginalLoc.X, OriginalLoc.X + Length, THROWING_FLY_TIME, EFCEase::Linear);
			TweenLocX.ApplyEasing.AddUFunction(this, n"FlyingLocationX");
			TweenLocX.Start();
		}
		UFCTweenBPActionFloat TweenLocZ = UFCTweenBPActionFloat::TweenFloat(OriginalLoc.Z, 50 * ActorScale3D.Z, THROWING_FLY_TIME, EFCEase::InBack);
		TweenLocZ.ApplyEasing.AddUFunction(this, n"FlyingLocationZ");
		TweenLocZ.OnComplete.AddUFunction(this, n"EmergeDone");
		TweenLocZ.OnComplete.AddUFunction(this, n"InitMovement");
		TweenLocZ.Start();

		UFCTweenBPActionRotator TweenRot = UFCTweenBPActionRotator::TweenRotator(OriginalRot, TargetRot, 0.5, EFCEase::OutSine);
		TweenRot.ApplyEasing.AddUFunction(this, n"FlyingRotation");
		TweenRot.Start();
	}

	UFUNCTION()
	void FlyingLocationX(float32 NewLoc)
	{
		FVector Loc = GetActorLocation();
		SetActorLocation(FVector(NewLoc, Loc.Y, Loc.Z));
	}

	UFUNCTION()
	void FlyingLocationXY(FVector2D NewLoc)
	{
		FVector Loc = GetActorLocation();
		SetActorLocation(FVector(NewLoc.X, NewLoc.Y, Loc.Z));
	}

	UFUNCTION()
	void FlyingLocationZ(float32 NewLoc)
	{
		FVector Loc = GetActorLocation();
		SetActorLocation(FVector(Loc.X, Loc.Y, NewLoc));
	}

	UFUNCTION()
	void FlyingRotation(FRotator NewRot)
	{
		SetActorRotation(NewRot);
	}

	void ResetRotation()
	{
		SetActorRotation(FRotator(0, -90, 0));
	}

	void SetStencilValue(int value)
	{
		BodyMesh.SetCustomDepthStencilValue(value);
	}
}
