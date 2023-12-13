delegate void FAttackHitDelegate();
delegate void FZombieDieDelegate();
delegate void FZombieReachHomeDelegate(int Damage);

const float ENDSCREEN_MOVING_LIMIT = 1800.f;

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
	UParticleSystemComponent StatusEffect;
	default StatusEffect.Activate(false);
	default StatusEffect.AutoActivate = false;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage EmergeAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage DamageAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> NoWpnAttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> WeaponAttackAnim;

	TArray<UAnimMontage> AttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> DeadAnims;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimationAsset> DeadLoopAnims;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent HitSFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent DeadSFX;

	UPROPERTY(BlueprintReadWrite, Category = Stats)
	float MoveSpeed = 100;
	UPROPERTY(BlueprintReadWrite, Category = Stats)
	int HP = 200;

	UZombieAnimInst AnimateInst;
	FAttackHitDelegate AttackHitEvent;
	FZombieDieDelegate ZombDieEvent;
	FZombieReachHomeDelegate ZombieReachEvent;

	float baseMoveSpeed;
	float delayMove = 3;
	int currentDeadAnim = 0;
	bool bIsDead = false;
	bool bIsAttacking = false;
	float bMovingLimit = 900;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AnimateInst = Cast<UZombieAnimInst>(ZombieSkeleton.GetAnimInstance());
		if (Math::RandBool() == true)
		{
			RightHandWp.StaticMesh = WeaponList[Math::RandRange(0, WeaponList.Num() - 1)];
			AttackAnim = WeaponAttackAnim;
		}
		else
		{
			RightHandWp.StaticMesh = nullptr;
		}
		if (Math::RandBool() == true)
		{
			LeftHandWp.StaticMesh = WeaponList[Math::RandRange(0, WeaponList.Num() - 1)];
			AttackAnim = WeaponAttackAnim;
			if (RightHandWp.StaticMesh == nullptr)
			{
				AnimateInst.bIsMirror = true;
			}
			else
			{
				AnimateInst.bIsMirror = Math::RandBool();
			}
		}
		else
		{
			LeftHandWp.StaticMesh = nullptr;
		}
		if (RightHandWp.StaticMesh == nullptr && LeftHandWp.StaticMesh == nullptr)
		{
			AttackAnim = NoWpnAttackAnim;
			AnimateInst.bIsMirror = Math::RandBool();
		}
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		AnimateInst.Montage_Play(EmergeAnim);
		baseMoveSpeed = MoveSpeed;
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
			else if (loc.X < bMovingLimit || !bIsAttacking)
			{
				loc.X += MoveSpeed * DeltaSeconds;
				if (loc.X > bMovingLimit)
				{
					if (AttackHitEvent.IsBound())
					{
						loc.X = bMovingLimit;
						bIsAttacking = true;
						Attacking(nullptr, false);
					}
					else
					{
						bMovingLimit = ENDSCREEN_MOVING_LIMIT;
					}
				}
			}
			if (loc.Z <= -10 || loc.X > 1600)
			{
				if (!bIsDead)
				{
					ZombieReachEvent.ExecuteIfBound(10);
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

	UFUNCTION()
	void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		Print("Hello");
		if (HP > 0)
		{
			ABowling pawn = Cast<ABowling>(OtherActor);
			if (pawn != nullptr)
			{
				if (UpdateHP(-50) > 0)
				{
					AnimateInst.Montage_Play(DamageAnim);
					FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
					if (bIsAttacking)
					{
						AnimateInst.OnMontageBlendingOut.AddUFunction(this, n"Attacking");
					}
					if (pawn.Status == EStatus::Fire)
					{
						StatusEffect.Activate(true);
						System::SetTimer(this, n"Burning", 1, true);
					}
					delayMove = 1;
				}
				Print("Hit:" + HP);
			}
		}
	}

	UFUNCTION()
	void Dead(UAnimMontage Montage, bool bInterrupted)
	{
		ZombieSkeleton.PlayAnimation(DeadLoopAnims[currentDeadAnim], true);
		ZombDieEvent.ExecuteIfBound();
	}

	UFUNCTION()
	void Attacking(UAnimMontage Montage, bool bInterrupted)
	{
		AnimateInst.OnMontageBlendingOut.Clear();
		AnimateInst.Montage_Play(AttackAnim[Math::RandRange(0, AttackAnim.Num() - 1)]);
	}

	UFUNCTION()
	void Burning()
	{
		if (UpdateHP(-10) <= 0)
		{
			System::ClearTimer(this, "Burning");
		}
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
		}
		return HP;
	}

	UFUNCTION()
	void AttackHit()
	{
		AttackHitEvent.ExecuteIfBound();
	}

	UFUNCTION()
	void StopAttacking()
	{
		delayMove = 1.5f;
		bIsAttacking = false;
		AnimateInst.Montage_Stop(0.5f);
		bMovingLimit = ENDSCREEN_MOVING_LIMIT;
	}
}
