class AThrowable : ABullet
{
	UPROPERTY(DefaultComponent)
	UStaticMeshComponent Mesh;
	default Mesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default Mesh.SetCollisionObjectType(ECollisionChannel::Projectile);

	// This mesh is just for testing
	UPROPERTY(DefaultComponent)
	UStaticMeshComponent DamageRangeMesh;
	default DamageRangeMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default DamageRangeMesh.SetCollisionObjectType(ECollisionChannel::Projectile);

	UPROPERTY()
	float MaxHeight = 500;

	UPROPERTY()
	float ExplosionRadius = 150;

	UFCTweenBPActionFloat FloatTween;
	float OriginalZ;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		DamageRangeMesh.SetRelativeScale3D(FVector::OneVector * (ExplosionRadius / 50));
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		OriginalZ = GetActorLocation().Z;
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(OriginalZ, MaxHeight, 0.5, EFCEase::OutSine, );
		FloatTween.ApplyEasing.AddUFunction(this, n"FlyTrajectory");
		FloatTween.Start();
		System::SetTimer(this, n"FlyOut", 1.001, false);
	}

	UFUNCTION()
	void FlyOut()
	{
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(MaxHeight, 25, 0.5, EFCEase::InSine);
		FloatTween.ApplyEasing.AddUFunction(this, n"FlyTrajectory");
		FloatTween.OnComplete.AddUFunction(this, n"OnFlyOutEnd");
		FloatTween.Start();
	}

	UFUNCTION()
	private void FlyTrajectory(float32 Value)
	{
		FVector NewLoc = GetActorLocation();
		SetActorLocation(FVector(NewLoc.X, NewLoc.Y, Value));
	}

	UFUNCTION()
	void OnFlyOutEnd()
	{
		DealDamage(nullptr);
		OnBulletImpact();
	}

	bool DealDamage(AActor OtherActor) override
	{
		TArray<EObjectTypeQuery> traceObjectTypes;
		traceObjectTypes.Add(EObjectTypeQuery::Enemy);
		TArray<AActor> ignoreActors;
		TArray<AActor> outActors;
		System::SphereOverlapActors(GetActorLocation(), ExplosionRadius, traceObjectTypes, nullptr, ignoreActors, outActors);
		bool bHit = false;
		for (AActor overlappedActor : outActors)
		{
			bHit = bHit || Super::DealDamage(overlappedActor);
		}
		return bHit;
	}
};