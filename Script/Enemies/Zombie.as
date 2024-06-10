const float ENDSCREEN_MOVING_LIMIT = 1650.f;

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
	// FFloatDelegate DOnAttackHit;
	FNameDelegate DOnZombDie;
	FFloatNameDelegate DOnZombieReach;

	// float speedModifier = 1;
	float delayMove = 2.f;
	int currentDeadAnim = 0;
	bool bIsAttacking = false;
	float MovingLimit;

	UPROPERTY(DefaultComponent)
	UAbilitySystem AbilitySystem;

	private UDamageResponseComponent Target;
	private UMaterialInstanceDynamic DynamicMat;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default MovementComp.bShouldBounce = true;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.AutoActivate = false;
	// TODO: refactor movment comp so it can be bounced off also

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AnimateInst = Cast<UZombieAnimInst>(ZombieSkeleton.GetAnimInstance());
		DynamicMat = Material::CreateDynamicMaterialInstance(ZombieSkeleton.GetMaterial(0));
		ZombieSkeleton.SetMaterial(0, DynamicMat);
		// Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		System::SetTimer(this, n"EmergeDone", delayMove, true);

		AbilitySystem.RegisterAttrSet(UPrimaryAttrSet);
		AbilitySystem.RegisterAttrSet(UAttackAttrSet);
		AbilitySystem.RegisterAttrSet(UMovementAttrSet);
		AbilitySystem.EOnPostSetCurrentValue.AddUFunction(this, n"OnPostSetCurrentValue");

		DamageResponseComponent.Initialize(AbilitySystem);
		DamageResponseComponent.DOnHitCue.AddUFunction(this, n"TakeHitCue");
		DamageResponseComponent.DOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.DOnDeadCue.AddUFunction(this, n"DeadCue");

		StatusResponseComponent.Initialize(AbilitySystem);

		MovementResponseComponent.Initialize(AbilitySystem);
	}

	UFUNCTION()
	private void OnPostSetCurrentValue(FName AttrName, float Value)
	{
		if (AttrName == n"MoveSpeed")
		{
			AnimateInst.SetMoveSpeed(Value);
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		delayMove -= DeltaSeconds;
		if (delayMove <= 0)
		{
			if (AnimateInst.AnimMoveSpeed == 0)
			{
				AnimateInst.SetMoveSpeed(AbilitySystem.GetValue(n"MoveSpeed"));
			}

			FVector loc = GetActorLocation();
			if (DamageResponseComponent.bIsDead)
			{
				// Fall down animation should run at constant speed
				loc.Z -= 80 * DeltaSeconds;
			}
			else if (loc.X < MovingLimit || !bIsAttacking)
			{
				loc.X += AnimateInst.AnimMoveSpeed * DeltaSeconds;
				if (loc.X > MovingLimit)
				{
					if (IsValid(Target))
					{
						loc.X = MovingLimit;
						bIsAttacking = true;
						StartAttacking(nullptr, false);
					}
					else
					{
						MovingLimit = ENDSCREEN_MOVING_LIMIT;
					}
				}
			}
			if (loc.Z <= -10 || loc.X > 1600)
			{
				if (!DamageResponseComponent.bIsDead)
				{
					DOnZombieReach.ExecuteIfBound(AbilitySystem.GetValue(n"Attack"), GetName());
				}
				DestroyActor();
			}
			else
			{
				SetActorLocation(loc);
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
		if (TargetResponseComponent.IsTargetable(OtherActor))
		{
			Target = UDamageResponseComponent::Get(OtherActor);
			if (IsValid(Target))
			{
				Target.DOnDeadCue.AddUFunction(this, n"StopAttacking");
				SetMovingLimit(OtherActor.GetActorLocation().X - 100);
			}
		}
	}

	UFUNCTION()
	void StartAttacking(UAnimMontage Montage, bool bInterrupted)
	{
		AnimateInst.OnMontageEnded.Clear();
		int random = Math::RandRange(0, AttackAnim.Num() - 1);
		AnimateInst.Montage_Play(AttackAnim[random], AttackAnim[random].PlayLength / AbilitySystem.GetValue(n"AttackCooldown"));
	}

	// Called when the animation trigger an event
	UFUNCTION()
	void AttackHit()
	{
		if (IsValid(Target))
		{
			Target.TakeHit(AbilitySystem.GetValue(n"Attack"));
		}
	}

	UFUNCTION()
	void StopAttacking()
	{
		delayMove = 1.5f;
		bIsAttacking = false;
		AnimateInst.Montage_Stop(0.5f);
		MovingLimit = ENDSCREEN_MOVING_LIMIT;
		Target.DOnDeadCue.UnbindObject(this);
		Target = nullptr;
	}

	UFUNCTION()
	void SetData(FZombieDT DataRow)
	{
		TMap<FName, float32> Data;
		Data.Add(n"MaxHP", DataRow.HP);
		Data.Add(n"Attack", DataRow.Atk);
		Data.Add(n"MaxSpeed", DataRow.Speed);
		Data.Add(n"AttackCooldown", DataRow.AttackCooldown);

		AbilitySystem.ImportData(Data);

		AnimateInst.SetMoveSpeed(DataRow.Speed);
		SetActorScale3D(DataRow.Scale);
		CoinValue = DataRow.CoinDropAmount;
	}

	UFUNCTION()
	void SetMovingLimit(float iLimit)
	{
		MovingLimit = iLimit - (GetActorScale3D().Y - 1) * 75.f;
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
		DynamicMat.SetScalarParameterValue(n"IsHit", 1);
		System::SetTimer(this, n"EndHitFlash", 0.25, false);
		AnimateInst.Montage_Play(DamageAnim);
		FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
		if (bIsAttacking)
		{
			AnimateInst.OnMontageEnded.AddUFunction(this, n"StartAttacking");
		}
		delayMove = 1;
	}

	UFUNCTION()
	void DeadCue()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		AnimateInst.StopSlotAnimation();
		currentDeadAnim = Math::RandRange(0, DeadAnims.Num() - 1);
		AnimateInst.Montage_Play(DeadAnims[currentDeadAnim]);
		delayMove = DeadAnims[currentDeadAnim].GetPlayLength();
		DOnZombDie.ExecuteIfBound(GetName());

		FMODBlueprint::PlayEventAtLocation(this, DeadSFX, GetActorTransform(), true);

		ACoin SpawnedActor = Cast<ACoin>(SpawnActor(CoinTemplate, GetActorLocation(), GetActorRotation()));
		SpawnedActor.ExpectValueToCoinType(CoinValue);
	}

	UFUNCTION(BlueprintCallable)
	void EmergeDone()
	{
		AnimateInst.bIsEmergeDone = true;
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
