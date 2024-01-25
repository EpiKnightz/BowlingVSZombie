class ASupporterGun : ACompanion
{
#if EDITOR
	default RightHandWp.AttachTo(CompanionSkeleton, n"RightGun");
#endif

	UPROPERTY(BlueprintReadWrite, Category = Bullet)
	TSubclassOf<ABullet> BulletTemplate;

	// UPROPERTY(DefaultComponent, Attach = Collider)
	// UNiagaraComponent NiagaraComp;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem MuzzleVFX;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RightHandWp.AttachTo(CompanionSkeleton, n"RightGun");
		Super::BeginPlay();
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		ABowling pawn = Cast<ABowling>(OtherActor);
		if (pawn != nullptr)
		{
			// Attack();
			System::SetTimer(this, n"Attack", 0.15f, true);
			AnimateInst.Montage_Play(AttackAnim);
		}
	}

	UFUNCTION()
	void Attack()
	{
		// ABullet SpawnedActor = Cast<ABullet>()
		Niagara::SpawnSystemAtLocation(MuzzleVFX, RightHandWp.GetSocketLocation(n"Muzzle"), FRotator(0, 180, 0));
		SpawnActor(BulletTemplate, RightHandWp.GetSocketLocation(n"Muzzle"), GetActorRotation());
		AtksLeft--;
		if (AtksLeft <= 0)
		{
			// NiagaraComp =
			System::ClearTimer(this, "Attack");
			AtksLeft = NumberOfAtks;
		}
	}
}
