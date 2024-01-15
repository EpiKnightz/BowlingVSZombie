class ABullet : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent BulletMesh;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		FVector loc = GetActorLocation();
		if (loc.Z <= -10 || loc.X < -1600)
		{
			DestroyActor();
		}
	}
}
