class ABullet : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;

	UPROPERTY(DefaultComponent)
	UNiagaraComponent BulletSystem;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent ProjectileMovement;
	default ProjectileMovement.InitialSpeed = 1000;
	default ProjectileMovement.MaxSpeed = 1000;
	default ProjectileMovement.ProjectileGravityScale = 0;
	default ProjectileMovement.Velocity = FVector(0, 1, 0);

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
