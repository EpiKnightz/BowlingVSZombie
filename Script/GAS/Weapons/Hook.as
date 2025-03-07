class AHook : ABullet
{
	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent Mesh;
	default Mesh.SetCollisionProfileName(n"NoCollision");
	default MovementComp.Velocity = FVector(-1, 0, 0);

	FActorEvent EOnOverlap;

	void OnBulletImpactCue() override
	{
		// Don't destroy bullet
		// Super::OnBulletImpact();
	}

	bool DealDamage(AActor OtherActor) override
	{
		if (TargetResponseComponent.IsZombie(OtherActor))
		{
			MovementComp.StopMovementImmediately();
			AttachToActor(OtherActor);
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			EOnOverlap.Broadcast(OtherActor);
			return true;
		}
		return false;
	}

	UFUNCTION()
	void HookComplete()
	{
		DetachFromActor();
		DestroyActor();
	}
};