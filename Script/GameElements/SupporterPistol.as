class ASupporterPistol : ASupporterGun
{
	// #if EDITOR
	// 	default RightHandWp.AttachTo(CompanionSkeleton, n"RightPistol");

	// #endif

	UFUNCTION(BlueprintOverride, Meta = (NoSuperCall))
	void ConstructionScript()
	{
		RightHandWp.AttachTo(CompanionSkeleton, n"RightPistol");
	}

	// UFUNCTION(BlueprintOverride)
	// void BeginPlay()
	// {
	// 	RightHandWp.AttachTo(CompanionSkeleton, n"RightPistol");
	// 	Super::BeginPlay();
	// }

	UFUNCTION(BlueprintOverride, Meta = (NoSuperCall))
	void ActorBeginOverlap(AActor OtherActor)
	{
		ABowling pawn = Cast<ABowling>(OtherActor);
		if (pawn != nullptr)
		{
			pawn.DOnHit.BindUFunction(this, n"OnHit");
		}
	}

	UFUNCTION()
	void OnHit(AActor OtherActor)
	{
		AZombie zomb = Cast<AZombie>(OtherActor);
		if (zomb != nullptr)
		{
			SetActorRotation(FRotator::MakeFromX(OtherActor.GetActorLocation() - CompanionSkeleton.GetSocketLocation(n"RightPistol")) + FRotator(0, 270, 0));
			AnimateInst.Montage_Play(AttackAnim);
			System::SetTimer(this, n"Attack", 0.125f, true);
		}
	}
}
