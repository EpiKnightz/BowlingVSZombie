const float BASE_VFX_TIME = 5;

class ALaser : AProjectile
{
	UPROPERTY(RootComponent, DefaultComponent)
	UNiagaraComponent BulletSystem;

	UPROPERTY(DefaultComponent)
	UCapsuleComponent Collider;
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;
	default Collider.CollisionEnabled = ECollisionEnabled::NoCollision;

	default MovementComp.InitialSpeed = 0;
	default MovementComp.MaxSpeed = 0;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.Velocity = FVector(0, 0, 0);

	default InitialLifeSpan = 5.25;

	UPROPERTY(BlueprintReadWrite, Category = Attributes)
	float LaserLifeTime = 5;
	UPROPERTY(BlueprintReadWrite, Category = Attributes)
	float HitInterval = 0.5;
	float DelayActivation = 0.75;
	float DeactivationTime = 3.5;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem HitVFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent FiredSFX;

	private TArray<EObjectTypeQuery> TraceObjectTypes;
	private TArray<AActor> IgnoreActors;
	private TArray<AActor> OutActors;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TraceObjectTypes.Add(EObjectTypeQuery::Enemy);
		float CustomDilation = BASE_VFX_TIME / LaserLifeTime;
		BulletSystem.SetCustomTimeDilation(CustomDilation);
		DelayActivation /= CustomDilation;
		DeactivationTime /= CustomDilation;

		if (DelayActivation > 0)
		{
			System::SetTimer(this, n"ActivateLaser", DelayActivation, false);
		}
		else
		{
			ActivateLaser();
		}
	}

	UFUNCTION()
	void ActivateLaser()
	{
		System::ClearTimer(this, "TraceForHit");
		TraceForHit();
		System::SetTimer(this, n"TraceForHit", HitInterval, true);
		System::SetTimer(this, n"DeactivateLaser", DeactivationTime, false);
		PlaySFX();
	}

	UFUNCTION()
	void TraceForHit()
	{
		System::ComponentOverlapActors(Collider, Collider.WorldTransform, TraceObjectTypes, nullptr, IgnoreActors, OutActors);
		for (AActor overlappedActor : OutActors)
		{
			UDamageResponseComponent DamageResponse = UDamageResponseComponent::Get(overlappedActor);
			if (IsValid(DamageResponse) && ProjectileDataComp.GetAttack() != ProjectileSpec::UNINIT_VALUE)
			{
				DamageResponse.DOnTakeHit.ExecuteIfBound(ProjectileDataComp.GetAttack());
				auto StatusResponse = UStatusResponseComponent::Get(overlappedActor);
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(ProjectileDataComp.GetEffects());
				}
				OnBulletImpact();
			}
		}
		// Print("Hit");
		OutActors.Empty();
	}

	UFUNCTION()
	private void DeactivateLaser()
	{
		System::ClearTimer(this, "TraceForHit");
	}

	void OnBulletImpact()
	{
		Niagara::SpawnSystemAtLocation(HitVFX, GetActorLocation());
	}

	UFUNCTION()
	void PlaySFX()
	{
		FMODBlueprint::PlayEventAtLocation(this, FiredSFX, GetActorTransform(), true);
	}
}
