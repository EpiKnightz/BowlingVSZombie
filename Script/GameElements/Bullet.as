class ABullet : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;

	UPROPERTY(DefaultComponent)
	UNiagaraComponent BulletSystem;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent ProjectileMovement;
	default ProjectileMovement.InitialSpeed = 1500;
	default ProjectileMovement.MaxSpeed = 1500;
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
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
	}

	UFUNCTION()
	private void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		Niagara::SpawnSystemAtLocation(HitVFX, GetActorLocation());
		DestroyActor();
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
		ActorBeginHit(nullptr, OtherActor, nullptr, FVector(), FHitResult());
	}
}
