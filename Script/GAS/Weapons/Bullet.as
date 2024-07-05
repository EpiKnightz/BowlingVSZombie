class ABullet : AProjectile
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;

	UPROPERTY(DefaultComponent)
	UNiagaraComponent BulletSystem;

	default MovementComp.InitialSpeed = 1500;
	default MovementComp.MaxSpeed = 1500;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.Velocity = FVector(0, 1, 0);

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Untargetable;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem HitVFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent FiredSFX;

	// float Attack = 10;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FMODBlueprint::PlayEventAtLocation(this, FiredSFX, GetActorTransform(), true);
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
	}

	UFUNCTION()
	void SetData(FSurvivorDT SurvivorData)
	{
		ProjectileDataComp.ProjectileData = SurvivorData;
	}

	UFUNCTION()
	private void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		if (TargetResponseComponent.IsTargetable(OtherActor))
		{
			auto DamageResponse = UDamageResponseComponent::Get(OtherActor);
			if (IsValid(DamageResponse))
			{
				// This is because the atk should already been buff/debuff at spawned
				DamageResponse.TakeHit(ProjectileDataComp.ProjectileData.Atk);
				auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(ProjectileDataComp.ProjectileData.EffectTags);
				}
			}
		}
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
