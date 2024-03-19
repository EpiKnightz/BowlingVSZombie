delegate void FAttackHitDelegate(int Damage);
delegate void FZombieDieDelegate(FName actorName);
delegate void FZombieReachHomeDelegate(int Damage, FName actorName);

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

	// UPROPERTY(BlueprintReadWrite, Category = Animation)
	// UAnimMontage EmergeAnim;

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

	UPROPERTY(BlueprintReadWrite, Category = Stats)
	float MoveSpeed = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	int HP = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	int Atk = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	int Dmg = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	float AtkSpeed = 1;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	EAttackType AtkType = EAttackType::Punch;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	float CoinValue;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieStatusTable;

	UPROPERTY(BlueprintReadOnly)
	bool bIsEmergeDone = false;

	UPROPERTY(Category = Drop)
	TSubclassOf<ACoin> CoinTemplate;

	UCustomAnimInst AnimateInst;
	FAttackHitDelegate AttackHitDelegate;
	FZombieDieDelegate ZombDieDelegate;
	FZombieReachHomeDelegate ZombieReachDelegate;

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
		AnimateInst = Cast<UCustomAnimInst>(ZombieSkeleton.GetAnimInstance());
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		// AnimateInst.Montage_Play(EmergeAnim);
		System::SetTimer(this, n"EmergeDone", delayMove, true);
	}

	UFUNCTION(BlueprintCallable)
	void EmergeDone()
	{
		bIsEmergeDone = true;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		delayMove -= DeltaSeconds;
		if (delayMove <= 0)
		{
			if (MoveSpeed == 0)
			{
				MoveSpeed = baseMoveSpeed;
			}

			FVector loc = GetActorLocation();
			if (bIsDead)
			{
				loc.Z -= MoveSpeed * DeltaSeconds;
			}
			else if (loc.X < MovingLimit || !bIsAttacking)
			{
				loc.X += MoveSpeed * DeltaSeconds * speedModifier;
				if (loc.X > MovingLimit)
				{
					if (AttackHitDelegate.IsBound())
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
					ZombieReachDelegate.ExecuteIfBound(Dmg, GetName());
				}
				DestroyActor();
			}
			else
			{
				SetActorLocation(loc);
			}
		}
		else if (MoveSpeed > 0)
		{
			MoveSpeed = 0;
		}
	}

	void SetSkeletonMesh(USkeletalMesh mesh)
	{
		ZombieSkeleton.SkeletalMeshAsset = mesh;
	}

	void SetWeapon(UStaticMesh RightHand, UStaticMesh LeftHand, bool bCanDualWield, EAttackType iAtkType)
	{
		AtkType = iAtkType;
		RightHandWp.StaticMesh = RightHand;
		LeftHandWp.StaticMesh = LeftHand;
		if (RightHand != nullptr || LeftHand != nullptr)
		{
			AttackAnim = WeaponAttackAnim;
			AnimateInst.bIsMirror = bCanDualWield ? Math::RandBool() : (LeftHand != nullptr && AtkType != EAttackType::Shield);
		}
		else
		{
			AttackAnim = NoWpnAttackAnim;
			AnimateInst.bIsMirror = Math::RandBool();
		}

		if (AtkType == EAttackType::Shield)
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
	void TakeHit(int Damage, EStatus status = EStatus::None)
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
			CheckForStatusEffects(status);
			delayMove = 1;
		}
	}

	void CheckForStatusEffects(EStatus status)
	{
		if (status != EStatus::None)
		{
			FZombieStatusDT Row;
			ZombieStatusTable.FindRow(Utilities::StatusEnumToFName(status), Row);
			if (Row.Duration != 0)
			{
				switch (status)
				{
					case EStatus::Fire:
						UDoTComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status)).Init(Row);
						break;
					case EStatus::Chill:
						UChillingComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status)).Init(Row);
						break;
					case EStatus::Freeze:
						UFreezeComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status)).Init(Row);
						break;
					case EStatus::Poison:
						break;
					default:
						break;
				}
			}
		}
	}

	UFUNCTION()
	void Dead(UAnimMontage Montage, bool bInterrupted)
	{
		// ZombieSkeleton.PlayAnimation(DeadLoopAnims[currentDeadAnim], false);
		AnimateInst.StopSlotAnimation();
		AnimateInst.PlaySlotAnimationAsDynamicMontage(DeadLoopAnims[currentDeadAnim], n"DefaultSlot", 0, 0);
		ZombDieDelegate.ExecuteIfBound(GetName());
	}

	UFUNCTION()
	void Attacking(UAnimMontage Montage, bool bInterrupted)
	{
		AnimateInst.OnMontageBlendingOut.Clear();
		AnimateInst.Montage_Play(AttackAnim[Math::RandRange(0, AttackAnim.Num() - 1)], AtkSpeed * speedModifier);
	}

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
		AttackHitDelegate.ExecuteIfBound(Atk);
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
		MoveSpeed = baseMoveSpeed = iSpeed;
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
}
