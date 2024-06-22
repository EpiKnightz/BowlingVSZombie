const float ENDSCREEN_X_LIMIT = 1650;
const float ENDSCREEN_Y_LIMIT = 500;
const float ENDSCREEN_Z_LIMIT = -10;
const float WAIT_TARGET_DEAD_TIME = 1.5;
const float DAMAGE_DELAY = 0.5;
const float DEAD_FALL_SPEED = 80;

enum EAttackType
{
	Punch,
	OneHand,
	DualWield,
	Shield,
	Pistol,
	Gun
}

class AZombie : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent ZombieSkeleton;

	UPROPERTY(DefaultComponent, Attach = ZombieSkeleton, AttachSocket = RightHand)
	UStaticMeshComponent RightHandWp;

	UPROPERTY(DefaultComponent, Attach = ZombieSkeleton, AttachSocket = LeftHand)
	UStaticMeshComponent LeftHandWp;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> WeaponList;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	UPROPERTY(DefaultComponent)
	UMovementResponseComponent MovementResponseComponent;

	UPROPERTY(DefaultComponent)
	UAttackResponseComponent AttackResponseComponent;

	UPROPERTY(DefaultComponent)
	UStatusResponseComponent StatusResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Zombie;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem SmackVFX;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage DamageAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> NoWpnAttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> WeaponAttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> ShieldAttackAnim;

	TArray<UAnimMontage> AttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> DeadAnims;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent HitSFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent DeadSFX;

	// UPROPERTY(BlueprintReadWrite, Category = Stats)
	// EAttackType AtkType = EAttackType::Punch;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	float CoinValue;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieStatusTable;

	UPROPERTY(Category = Drop)
	TSubclassOf<ACoin> CoinTemplate;

	UZombieAnimInst AnimateInst;
	FNameDelegate DOnZombDie;
	FFloatNameDelegate DOnZombieReach;

	// float speedModifier = 1;
	float delayMove = 2.f;
	int currentDeadAnim = 0;
	bool bIsAttacking = false;

	UPROPERTY(DefaultComponent)
	ULiteAbilitySystem AbilitySystem;

	private UDamageResponseComponent Target; // Or maybe allow multiple target here? would that be easier?
	private UMaterialInstanceDynamic DynamicMat;

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
		AnimateInst = Cast<UZombieAnimInst>(ZombieSkeleton.GetAnimInstance());
		DynamicMat = Material::CreateDynamicMaterialInstance(ZombieSkeleton.GetMaterial(0));
		ZombieSkeleton.SetMaterial(0, DynamicMat);
		// Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		System::SetTimer(this, n"EmergeDone", delayMove, false);

		AbilitySystem.RegisterAttrSet(UPrimaryAttrSet);
		AbilitySystem.RegisterAttrSet(UAttackAttrSet);
		AbilitySystem.RegisterAttrSet(UMovementAttrSet);
		AbilitySystem.EOnPostSetCurrentValue.AddUFunction(this, n"OnPostSetCurrentValue");

		DamageResponseComponent.Initialize(AbilitySystem);
		DamageResponseComponent.DOnHitCue.AddUFunction(this, n"TakeHitCue");
		DamageResponseComponent.DOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.DOnDeadCue.AddUFunction(this, n"DeadCue");

		StatusResponseComponent.Initialize(AbilitySystem);

		AttackResponseComponent.Initialize(AbilitySystem);
		AttackResponseComponent.EOnAnimHitNotify.AddUFunction(this, n"OnAttackHitNotify");

		MovementResponseComponent.Initialize(AbilitySystem);
		MovementResponseComponent.EOnBounceCue.AddUFunction(this, n"OnBounceCue");
		MovementResponseComponent.EOnPreAddForceCue.AddUFunction(this, n"OnPreAddForceCue");
		// Temporary
		MovementResponseComponent.StopLifeTime = 0;
	}

	UFUNCTION()
	private void OnPostSetCurrentValue(FName AttrName, float Value)
	{
		if (AttrName == n"MoveSpeed")
		{
			SetMoveSpeed(Value);
		}
		if (AttrName == n"AttackCooldown")
		{
			SetAttackCooldown(Value);
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		delayMove -= DeltaSeconds;
		if (delayMove <= 0)
		{
			if (AnimateInst.AnimMoveSpeed == 0 && !bIsAttacking)
			{
				if (IsValid(Target))
				{
					StartAttacking();
				}
				else
				{
					if (!CheckForNewTarget())
					{
						RestartMove();
					}
				}
			}

			FVector loc = GetActorLocation();
			if (DamageResponseComponent.bIsDead)
			{
				// Fall down animation should run at constant speed
				loc.Z -= DEAD_FALL_SPEED * DeltaSeconds;
				SetActorLocation(loc);
			}

			if (loc.Z <= ENDSCREEN_Z_LIMIT
				|| loc.X > ENDSCREEN_X_LIMIT
				|| loc.Y > ENDSCREEN_Y_LIMIT
				|| loc.Y < -ENDSCREEN_Y_LIMIT)
			{
				if (!DamageResponseComponent.bIsDead) // If not dead, meaning the zomb goes to end screen, Deal dmg to player
				{
					DOnZombieReach.ExecuteIfBound(AbilitySystem.GetValue(n"Attack"), GetName());
				}
				DestroyActor();
			}
		}
		else if (AnimateInst.AnimMoveSpeed > 0)
		{
			AnimateInst.SetMoveSpeed(0);
		}
	}

	void SetSkeletonMesh(USkeletalMesh mesh)
	{
		ZombieSkeleton.SkeletalMeshAsset = mesh;
	}

	void SetWeapon(UStaticMesh RightHand, UStaticMesh LeftHand, bool bCanDualWield, EAttackType iAtkType)
	{
		AnimateInst.AtkType = iAtkType;
		RightHandWp.StaticMesh = RightHand;
		LeftHandWp.StaticMesh = LeftHand;
		if (RightHand != nullptr || LeftHand != nullptr)
		{
			AttackAnim = WeaponAttackAnim;
			AnimateInst.bIsMirror = bCanDualWield ? Math::RandBool() : (LeftHand != nullptr && AnimateInst.AtkType != EAttackType::Shield);
		}
		else
		{
			AttackAnim = NoWpnAttackAnim;
			AnimateInst.bIsMirror = Math::RandBool();
		}

		if (AnimateInst.AtkType == EAttackType::Shield)
		{
			LeftHandWp.AttachTo(ZombieSkeleton, n"LeftShield");
			AttackAnim = ShieldAttackAnim;
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		OverlapActor(OtherActor);
	}

	UFUNCTION()
	bool OverlapActor(AActor OtherActor)
	{
		if (TargetResponseComponent.IsTargetable(OtherActor))
		{
			Target = UDamageResponseComponent::Get(OtherActor);
			if (IsValid(Target) && !bIsAttacking)
			{
				StartAttacking();
				Target.DOnDeadCue.AddUFunction(this, n"StopAttacking");
				Target.DOnDeadCue.AddUFunction(this, n"RemoveTarget");
				return true;
			}
		}
		return false;
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		if (IsValid(Target) && bIsAttacking)
		{
			if (Target == UDamageResponseComponent::Get(OtherActor))
			{
				StopAttacking();
				RemoveTarget();
			}
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
		int random = Math::RandRange(0, AttackAnim.Num() - 1);
		AnimateInst.Montage_Play(AttackAnim[random], AttackAnim[random].PlayLength / AbilitySystem.GetValue(n"AttackCooldown"));
	}

	// Called when the animation trigger an event
	UFUNCTION()
	void OnAttackHitNotify()
	{
		if (IsValid(Target))
		{
			Target.TakeHit(AbilitySystem.GetValue(n"Attack"));
		}
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
	void RemoveTarget()
	{
		if (Target != nullptr)
		{
			Target.DOnDeadCue.UnbindObject(this);
			Target = nullptr;
			delayMove = WAIT_TARGET_DEAD_TIME;
		}
	}

	UFUNCTION()
	bool CheckForNewTarget()
	{
		TArray<AActor> OverlappingActors;
		Collider.GetOverlappingActors(OverlappingActors, AObstacle);
		if (OverlappingActors.Num() > 0)
		{
			return OverlapActor(OverlappingActors[0]);
		}
		return false;
	}

	UFUNCTION()
	void SetData(FZombieDT DataRow)
	{
		TMap<FName, float32> Data;
		Data.Add(n"MaxHP", DataRow.HP);
		Data.Add(n"Attack", DataRow.Atk);
		Data.Add(n"MoveSpeed", DataRow.Speed);
		Data.Add(n"AttackCooldown", DataRow.AttackCooldown);
		Data.Add(n"Bounciness", DataRow.Bounciness);
		Data.Add(n"Accel", DataRow.Accel);

		AbilitySystem.ImportData(Data);

		SetMoveSpeed(DataRow.Speed);

		SetActorScale3D(DataRow.Scale);
		CoinValue = DataRow.CoinDropAmount;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Visual Cues:

	UFUNCTION()
	void TakeHitCue()
	{
		Niagara::SpawnSystemAtLocation(SmackVFX, GetActorLocation());
	}

	UFUNCTION()
	void TakeDamageCue()
	{
		StopAttacking();
		DynamicMat.SetScalarParameterValue(n"IsHit", 1);
		System::SetTimer(this, n"EndHitFlash", 0.25, false);
		System::ClearTimer(this, "EmergeDone");
		EmergeDone();
		AnimateInst.Montage_Play(DamageAnim);
		FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
		// MovementComp.StopMovementImmediately();
		delayMove = DAMAGE_DELAY;
	}

	UFUNCTION()
	void DeadCue()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		MovementComp.StopSimulating(FHitResult());
		AnimateInst.StopSlotAnimation();
		currentDeadAnim = Math::RandRange(0, DeadAnims.Num() - 1);
		AnimateInst.Montage_Play(DeadAnims[currentDeadAnim], 1);
		delayMove = DeadAnims[currentDeadAnim].GetPlayLength();
		DOnZombDie.ExecuteIfBound(GetName());

		FMODBlueprint::PlayEventAtLocation(this, DeadSFX, GetActorTransform(), true);

		ACoin SpawnedActor = Cast<ACoin>(SpawnActor(CoinTemplate, GetActorLocation(), GetActorRotation()));
		SpawnedActor.ExpectValueToCoinType(CoinValue);
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
		MovementResponseComponent.SetIsAccelable(true);
		AnimateInst.SetMoveSpeed(AbilitySystem.GetValue(n"MoveSpeed"));
		MovementResponseComponent.InitForce(FVector(1, 0, 0), 1);
	}
	// Called when being bounced/added force by something else
	UFUNCTION()
	private void OnPreAddForceCue(FVector Value)
	{
		MovementComp.StopMovementImmediately();
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
			MovementResponseComponent.InitForce(FVector(1, 0, 0), 1);
		}
	}

	void SetStencilValue(int value)
	{
		ZombieSkeleton.SetCustomDepthStencilValue(value);
	}

	UFUNCTION()
	void EndHitFlash()
	{
		DynamicMat.SetScalarParameterValue(n"IsHit", 0);
	}
}
