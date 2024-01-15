class ASupporterPistol : ASupporterGun
{

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RightHandWp.AttachTo(SupporterSkeleton, FName("RightPistol"));
		ASupporterGun::BeginPlay();
	}

	UFUNCTION(BlueprintOverride, Meta = (NoSuperCall))
	void ActorBeginOverlap(AActor OtherActor)
	{
		ABowling pawn = Cast<ABowling>(OtherActor);
		if (pawn != nullptr)
		{
			pawn.OnHit.BindUFunction(this, n"OnHit");
		}
	}

	UFUNCTION()
	void OnHit(AActor OtherActor)
	{
		AZombie zomb = Cast<AZombie>(OtherActor);
		if (zomb != nullptr)
		{
			SetActorRotation(FRotator::MakeFromX(OtherActor.GetActorLocation() - GetActorLocation()) + FRotator(0, 270, 0));
			AnimateInst.Montage_Play(FiringAnim);
			System::SetTimer(this, n"Fire", 0.125f, true);
		}
	}
}
