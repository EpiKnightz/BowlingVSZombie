class ABullet : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;

	UPROPERTY(DefaultComponent)
	UNiagaraComponent BulletSystem;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem HitVFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent FiredSFX;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FMODBlueprint::PlayEventAtLocation(this, FiredSFX, GetActorTransform(), true);
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		FVector loc = GetActorLocation();
		if (loc.Z <= -10 || loc.X < -1600)
		{
			DestroyActor();
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		Niagara::SpawnSystemAtLocation(HitVFX, GetActorLocation());
		DestroyActor();
	}
}
