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

	UPROPERTY(DefaultComponent, Attach = ZombieSkeleton, AttachSocket = SpineSocket)
	UNiagaraComponent StatusEffect;
	default StatusEffect.Activate(false);
	default StatusEffect.AutoActivate = false;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	UPROPERTY(DefaultComponent)
	USpeedResponseComponent SpeedResponseComponent;

	UPROPERTY(DefaultComponent)
	UStatusResponseComponent StatusResponseComponent;

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
	FFloatDelegate DOnAttackHit;
	FNameDelegate DOnZombDie;
	FFloatNameDelegate DOnZombieReach;

	float speedModifier = 1;
	float delayMove = 2.f;
	int currentDeadAnim = 0;
	bool bIsDead = false;
	bool bIsAttacking = false;
	float MovingLimit;

	UPROPERTY(DefaultComponent)
	UAbilitySystem AbilitySystem;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AnimateInst = Cast<UZombieAnimInst>(ZombieSkeleton.GetAnimInstance());
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		System::SetTimer(this, n"EmergeDone", delayMove, true);

		DamageResponseComponent.DOnApplyDamage.BindUFunction(this, n"TakeDamage");
		SpeedResponseComponent.DOnChangeMoveSpeedModifier.BindUFunction(this, n"UpdateSpeedModifier");
		StatusResponseComponent.DOnApplyStatus.BindUFunction(this, n"ApplyStatusEffects");

		AbilitySystem.RegisterAttrSet(UPrimaryAttrSet);
		AbilitySystem.RegisterAttrSet(UAttackAttrSet);
		AbilitySystem.RegisterAttrSet(UMoveableAttrSet);
	}

	UFUNCTION(BlueprintCallable)
	void EmergeDone()
	{
		AnimateInst.bIsEmergeDone = true;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		delayMove -= DeltaSeconds;
		if (delayMove <= 0)
		{
			if (AnimateInst.AnimMoveSpeed == 0)
			{
				AnimateInst.SetMoveSpeed(AbilitySystem.GetCurrentValue(n"MoveSpeed") * speedModifier);
			}

			FVector loc = GetActorLocation();
			if (bIsDead)
			{
				// Fall down animation should run at constant speed
				loc.Z -= 80 * DeltaSeconds;
			}
			else if (loc.X < MovingLimit || !bIsAttacking)
			{
				loc.X += AnimateInst.AnimMoveSpeed * DeltaSeconds * speedModifier;
				if (loc.X > MovingLimit)
				{
					if (DOnAttackHit.IsBound())
					{
						loc.X = MovingLimit;
						bIsAttacking = true;
						Attacking(nullptr, false);
					}
					else
					{
						MovingLimit = ENDSCREEN_MOVING_LIMIT;
					}
				}
			}
			if (loc.Z <= -10 || loc.X > 1600)
			{
				if (!bIsDead)
				{
					DOnZombieReach.ExecuteIfBound(AbilitySystem.GetCurrentValue(n"Attack"), GetName());
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

	/**
	 * Handles damage taken by the zombie actor. Checks the source of damage, applies damage, plays animations and sound effects,
	 * applies status effects if hit by a fire attack, and prints debug message.
	 */
	UFUNCTION()
	void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		if (AbilitySystem.GetCurrentValue(n"HP") > 0)
		{
			ABowling pawn = Cast<ABowling>(OtherActor);
			if (pawn != nullptr)
			{
				TakeHit(pawn.Attack, pawn.Status);
				// Print("Hit:" + HP);
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (AbilitySystem.GetCurrentValue(n"HP") > 0)
		{
			ABullet pawn2 = Cast<ABullet>(OtherActor);
			if (pawn2 != nullptr)
			{
				TakeHit(10);
			}
		}
	}

	UFUNCTION()
	void TakeHit(float Damage, EEffectType status = EEffectType::None)
	{
		Niagara::SpawnSystemAtLocation(SmackVFX, GetActorLocation());
		SetStencilValue(5);
		System::SetTimer(this, n"ResetStencilValue", 0.054, false);
		if (Damage > 0)
		{
			DamageResponseComponent.DOnApplyDamage.ExecuteIfBound(Damage);
			ApplyStatusEffects(status);
		}
	}

	void SetStencilValue(int value)
	{
		ZombieSkeleton.SetCustomDepthStencilValue(value);
	}

	UFUNCTION()
	void ResetStencilValue()
	{
		SetStencilValue(1);
	}

	UFUNCTION()
	void ApplyStatusEffects(EEffectType status)
	{
		if (status != EEffectType::None && AbilitySystem.GetCurrentValue(n"HP") > 0)
		{
			FStatusDT Row;
			ZombieStatusTable.FindRow(Utilities::StatusEnumToFName(status), Row);
			if (Row.Duration != 0)
			{
				UStatusComponent statusComp;
				switch (status)
				{
					case EEffectType::Fire:
						statusComp = UDoTComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status));
						break;
					case EEffectType::Chill:
						statusComp = UChillingComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status));
						break;
					case EEffectType::Freeze:
						statusComp = UFreezeComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status));
						break;
					case EEffectType::Poison:
						break;
					default:
						break;
				}
				statusComp.OnInit.BindUFunction(this, n"OnStatusInit");
				statusComp.OnEnd.BindUFunction(this, n"OnStatusEnd");
				statusComp.Init(Row);
			}
		}
	}

	UFUNCTION()
	void Attacking(UAnimMontage Montage, bool bInterrupted)
	{
		AnimateInst.OnMontageEnded.Clear();
		AnimateInst.Montage_Play(AttackAnim[Math::RandRange(0, AttackAnim.Num() - 1)], AbilitySystem.GetCurrentValue(n"AttackCooldown") * speedModifier);
	}

	UFUNCTION()
	bool CheckIsAlive()
	{
		if (AbilitySystem.GetCurrentValue(n"HP") <= 0)
		{
			DeadEffect();
			return false;
		}
		else
		{
			TakeDamageEffect();
			return true;
		}
	}

	UFUNCTION()
	bool TakeDamage(float Damage)
	{
		AbilitySystem.SetCurrentValue(n"Damage", Damage);
		AbilitySystem.Calculate(n"Damage");
		return CheckIsAlive();
	}

	UFUNCTION()
	void DeadEffect()
	{
		if (!bIsDead)
		{
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			AnimateInst.StopSlotAnimation();
			currentDeadAnim = Math::RandRange(0, DeadAnims.Num() - 1);
			AnimateInst.Montage_Play(DeadAnims[currentDeadAnim]);
			delayMove = DeadAnims[currentDeadAnim].GetPlayLength();
			bIsDead = true;
			DOnZombDie.ExecuteIfBound(GetName());

			FMODBlueprint::PlayEventAtLocation(this, DeadSFX, GetActorTransform(), true);

			ACoin SpawnedActor = Cast<ACoin>(SpawnActor(CoinTemplate, GetActorLocation(), GetActorRotation()));
			SpawnedActor.ExpectValueToCoinType(CoinValue);
		}
	}

	UFUNCTION()
	void TakeDamageEffect()
	{
		AnimateInst.Montage_Play(DamageAnim);
		FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
		if (bIsAttacking)
		{
			AnimateInst.OnMontageEnded.AddUFunction(this, n"Attacking");
		}
		delayMove = 1;
	}

	UFUNCTION()
	void AttackHit()
	{
		DOnAttackHit.ExecuteIfBound(AbilitySystem.GetCurrentValue(n"Attack"));
	}

	UFUNCTION()
	void StopAttacking()
	{
		delayMove = 1.5f;
		bIsAttacking = false;
		AnimateInst.Montage_Stop(0.5f);
		MovingLimit = ENDSCREEN_MOVING_LIMIT;
	}

	UFUNCTION()
	void SetData(int iHP, int iAtk, int iDmg, int iSpeed, float iAtkSpd, FVector iScale, float iCoinValue)
	{
		TMap<FName, float32> Data;
		Data.Add(n"HP", iHP);
		Data.Add(n"Attack", iAtk);
		Data.Add(n"Damage", iDmg);
		Data.Add(n"MoveSpeed", iSpeed);
		Data.Add(n"AttackCooldown", float32(iAtkSpd));

		AbilitySystem.ImportData(Data);

		AnimateInst.SetMoveSpeed(iSpeed);
		SetActorScale3D(iScale);
		CoinValue = iCoinValue;
		// Print("" + bMovingLimit);
	}

	UFUNCTION()
	void SetMovingLimit(float iLimit)
	{
		MovingLimit = iLimit - (GetActorScale3D().Y - 1) * 75.f;
	}

	UFUNCTION()
	void OnStatusInit(UNiagaraSystem VFX)
	{
		StatusEffect.Asset = VFX;
		StatusEffect.Activate(true);
	}

	UFUNCTION()
	void OnStatusEnd()
	{
		StatusEffect.Deactivate();
	}

	UFUNCTION()
	void UpdateSpeedModifier(float iSpeed)
	{
		speedModifier = iSpeed;
		// AnimateInst.Montage_SetPlayRate(att, speedModifier);
		AnimateInst.AnimPlayRate = speedModifier;
	}
}
