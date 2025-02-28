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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FMODBlueprint::PlayEventAtLocation(this, FiredSFX, GetActorTransform(), true);
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
	}

	UFUNCTION() // Currently unused anywhere
	void SetData(FWeaponDT WeaponData)
	{
		ProjectileDataComp.ProjectileData = WeaponData;
	}

	UFUNCTION()
	private void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		if (!DealDamage(OtherActor))
		{
			OnBulletImpact();
		}
	}

	bool DealDamage(AActor OtherActor)
	{
		if (TargetResponseComponent.IsTargetable(OtherActor))
		{
			auto DamageResponse = UDamageResponseComponent::Get(OtherActor);
			if (IsValid(DamageResponse)
				&& ProjectileDataComp.ProjectileData.Atk != ProjectileSpec::UNINIT_VALUE)
			{
				// This is because the atk should already been buff/debuff at spawned
				DamageResponse.DOnTakeHit.ExecuteIfBound(ProjectileDataComp.ProjectileData.Atk);
				auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(ProjectileDataComp.ProjectileData.EffectTags);
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

	void OnBulletImpact()
	{
		Niagara::SpawnSystemAtLocation(HitVFX, GetActorLocation());
		if (!ProjectileDataComp.ProjectileData.EffectTags.HasTagExact(GameplayTags::Status_Neutral_Piercing))
		{
			DestroyActor();
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (DealDamage(OtherActor))
		{
			OnBulletImpact();
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
