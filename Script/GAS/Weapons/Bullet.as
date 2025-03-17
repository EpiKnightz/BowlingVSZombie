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

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem HitVFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent FiredSFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent HitSFX;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (IsValid(FiredSFX))
		{
			FMODBlueprint::PlayEventAtLocation(this, FiredSFX, GetActorTransform(), true);
		}
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
	}

	UFUNCTION()
	private void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		DealDamage(OtherActor);
		OnBulletImpactCue(); // Need to test in case a piercing bullet get Hit
	}

	bool DealDamage(AActor OtherActor)
	{
		if (TargetResponseComponent.IsTargetable(OtherActor))
		{
			auto DamageResponse = UDamageResponseComponent::Get(OtherActor);
			float Attack = ProjectileDataComp.GetProjectileData().Atk;
			if (IsValid(DamageResponse)
				&& Attack != ProjectileSpec::UNINIT_VALUE)
			{
				// This is because the atk should already been buff/debuff at spawned
				DamageResponse.DOnTakeHit.ExecuteIfBound(Attack);
				auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(ProjectileDataComp.GetProjectileData().EffectTags);
				}
				return true;
			}
		}
		return false;
	}

	// UFUNCTION(BlueprintOverride)
	// void Tick(float DeltaSeconds)
	// {
	// 	FVector loc = GetActorLocation();
	// 	if (loc.Z <= -10 || loc.X < -1600)
	// 	{
	// 		DestroyActor();
	// 	}
	// }

	void OnBulletImpactCue()
	{
		if (IsValid(HitSFX))
		{
			FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
		}
		Niagara::SpawnSystemAtLocation(HitVFX, GetActorLocation());
		if (!ProjectileDataComp.GetProjectileData().EffectTags.HasTagExact(GameplayTags::Status_Neutral_Piercing))
		{
			DestroyActor();
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (DealDamage(OtherActor))
		{
			OnBulletImpactCue();
		}
	}

	void SetHoming(USceneComponent Target)
	{
		if (IsValid(Target))
		{
			MovementComp.bIsHomingProjectile = true;
			MovementComp.SetHomingTargetComponent(Target);
		}
	}
}
