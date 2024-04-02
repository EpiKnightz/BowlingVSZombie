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

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimSequenceBase> DeadLoopAnims;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent HitSFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent DeadSFX;

	// UPROPERTY(BlueprintReadWrite, Category = Stats)
	// float MoveSpeed = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	int HP = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	int Atk = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	int Dmg = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	float AtkSpeed = 1;
	// UPROPERTY(BlueprintReadWrite, Category = Stats)
	// EAttackType AtkType = EAttackType::Punch;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	float CoinValue;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieStatusTable;

	UPROPERTY(Category = Drop)
	TSubclassOf<ACoin> CoinTemplate;

	UZombieAnimInst AnimateInst;
	FIntDelegate DOnAttackHit;
	FNameDelegate DOnZombDie;
	FIntNameDelegate DOnZombieReach;

	int baseHP;
	float baseMoveSpeed;
	int baseAtk;
	int baseDmg;
	float baseAtkSpeed;
	float speedModifier = 1;
	float delayMove = 2.f;
	int currentDeadAnim = 0;
	bool bIsDead = false;
	bool bIsAttacking = false;
	float MovingLimit;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AnimateInst = Cast<UZombieAnimInst>(ZombieSkeleton.GetAnimInstance());
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		// AnimateInst.Montage_Play(EmergeAnim);
		System::SetTimer(this, n"EmergeDone", delayMove, true);

		DamageResponseComponent.DOnApplyDamage.BindUFunction(this, n"UpdateHP");
		SpeedResponseComponent.DOnChangeSpeedModifier.BindUFunction(this, n"UpdateSpeedModifier");
		StatusResponseComponent.DOnApplyStatus.BindUFunction(this, n"ApplyStatusEffects");
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
				AnimateInst.SetMoveSpeed(baseMoveSpeed);
			}

			FVector loc = GetActorLocation();
			if (bIsDead)
			{
				loc.Z -= AnimateInst.AnimMoveSpeed * DeltaSeconds;
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
					DOnZombieReach.ExecuteIfBound(Dmg, GetName());
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
		if (HP > 0)
		{
			ABowling pawn = Cast<ABowling>(OtherActor);
			if (pawn != nullptr)
			{
				TakeHit(int(pawn.Attack), pawn.Status);
				// Print("Hit:" + HP);
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (HP > 0)
		{
			ABullet pawn2 = Cast<ABullet>(OtherActor);
			if (pawn2 != nullptr)
			{
				TakeHit(10);
			}
		}
	}

	UFUNCTION()
	void TakeHit(int Damage, EEffectType status = EEffectType::None)
	{
		Niagara::SpawnSystemAtLocation(SmackVFX, GetActorLocation());
		if (UpdateHP(-Damage) > 0)
		{
			AnimateInst.Montage_Play(DamageAnim);
			FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
			if (bIsAttacking)
			{
				AnimateInst.OnMontageBlendingOut.AddUFunction(this, n"Attacking");
			}
			ApplyStatusEffects(status);
			delayMove = 1;
		}
	}

	UFUNCTION()
	void ApplyStatusEffects(EEffectType status)
	{
		if (status != EEffectType::None)
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
	void Dead(UAnimMontage Montage, bool bInterrupted)
	{
		// ZombieSkeleton.PlayAnimation(DeadLoopAnims[currentDeadAnim], false);
		AnimateInst.StopSlotAnimation();
		AnimateInst.PlaySlotAnimationAsDynamicMontage(DeadLoopAnims[currentDeadAnim], n"DefaultSlot", 0, 0);
		DOnZombDie.ExecuteIfBound(GetName());
	}

	UFUNCTION()
	void Attacking(UAnimMontage Montage, bool bInterrupted)
	{
		AnimateInst.OnMontageBlendingOut.Clear();
		AnimateInst.Montage_Play(AttackAnim[Math::RandRange(0, AttackAnim.Num() - 1)], AtkSpeed * speedModifier);
	}

	UFUNCTION()
	int UpdateHP(int Changes)
	{
		HP += Changes;
		if (HP <= 0 && !bIsDead)
		{
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			AnimateInst.StopSlotAnimation();
			currentDeadAnim = Math::RandRange(0, DeadAnims.Num() - 1);
			AnimateInst.Montage_Play(DeadAnims[currentDeadAnim]);
			AnimateInst.OnMontageBlendingOut.Clear();
			AnimateInst.OnMontageBlendingOut.AddUFunction(this, n"Dead");
			delayMove = 1.5f;
			bIsDead = true;
			FMODBlueprint::PlayEventAtLocation(this, DeadSFX, GetActorTransform(), true);

			ACoin SpawnedActor = Cast<ACoin>(SpawnActor(CoinTemplate, GetActorLocation(), GetActorRotation()));
			SpawnedActor.ExpectValueToCoinType(CoinValue);
		}
		return HP;
	}

	UFUNCTION()
	void AttackHit()
	{
		DOnAttackHit.ExecuteIfBound(Atk);
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
		HP = baseHP = iHP;
		Atk = baseAtk = iAtk;
		Dmg = baseDmg = iDmg;
		baseMoveSpeed = iSpeed;
		AnimateInst.SetMoveSpeed(baseMoveSpeed);
		AtkSpeed = baseAtkSpeed = iAtkSpd;
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
