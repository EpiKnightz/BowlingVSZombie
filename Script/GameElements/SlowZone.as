class ASlowZone : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;
	default Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY()
	float DeaccelAddend = 2500;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		ABowling bowl = Cast<ABowling>(OtherActor);
		if (bowl != nullptr)
		{
			bowl.SetDeaccelAddend(DeaccelAddend);
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		ABowling bowl = Cast<ABowling>(OtherActor);
		if (bowl != nullptr)
		{
			bowl.SetDeaccelAddend(0);
		}
	}
}
