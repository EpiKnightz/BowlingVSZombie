class ABowling : AActor
{
	float StopLifeTime = 1;
	float StopLifeTimeCounter = 0;

	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;
	default Collider.SimulatePhysics = false;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent BowlingMesh;
	default BowlingMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent, Attach = Collider)
	UNiagaraComponent EffectSystem;
	default EffectSystem.Activate(false);
	default EffectSystem.AutoActivate = false;

	UPROPERTY(BlueprintReadOnly)
	UMaterialInstanceDynamic MaterialInstance;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default MovementComp.bShouldBounce = true;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.AutoActivate = false;
	default MovementComp.MaxSpeed = 5000;
	default MovementComp.Velocity = FVector(-1, 0, 0);
	default MovementComp.Bounciness = 0.8;

	UPROPERTY()
	float BowlingDeaccel = 500;
	float DeaccelAddend = 0;

	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	float Attack = 10;

	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	EStatus Status = EStatus::Fire;

	FActorDelegate DOnHit;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0, MaterialInstance);

		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		MovementComp.OnProjectileBounce.AddUFunction(this, n"ActorBounce");
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (MovementComp.Velocity.SizeSquared() > 1000)
		{
			MovementComp.Velocity -= MovementComp.Velocity.GetSafeNormal() * (BowlingDeaccel + DeaccelAddend) * DeltaSeconds;
		}
		else if (MovementComp.Velocity != FVector::ZeroVector)
		{
			MovementComp.Velocity = FVector::ZeroVector;
		}
		else
		{
			StopLifeTimeCounter += DeltaSeconds;
			if (StopLifeTimeCounter > StopLifeTime)
			{
				DestroyActor();
			}
		}
	}

	void Fire(FVector Direction, float Force)
	{
		MovementComp.InitialSpeed = Force;
		MovementComp.Velocity = Direction * Force;
		MovementComp.Activate();
		if (Status != EStatus::None)
		{
			EffectSystem.Activate();
		}
	}

	void AddForce(FVector VelocityVector)
	{
		MovementComp.Velocity += VelocityVector;
	}

	UFUNCTION()
	void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		// Print("Real: " + Hit.Location, 100);
		// Print("Real vector: " + MovementComp.Velocity, 100);
		DOnHit.ExecuteIfBound(OtherActor);
		// Print("" + MovementComp.Velocity.Size(), 100);
	}

	UFUNCTION()
	void SetData(FBallDT Data)
	{
		BowlingMesh.StaticMesh = Data.BowlingMesh;
		Attack = Data.Atk;
		Status = Data.StatusEffect;
		EffectSystem.Asset = Data.StatusVFX;
	}

	UFUNCTION()
	void SetDeaccelAddend(float Addend)
	{
		DeaccelAddend = Addend;
	}

	UFUNCTION()
	void ActorBounce(const FHitResult&in Hit, const FVector&in ImpactVelocity)
	{
		MovementComp.Velocity *= 0.8;
		if (Hit.GetComponent().ComponentHasTag(n"Boundary"))
		{
			Gameplay::PlayWorldCameraShake(ShakeStyle, GetActorLocation(), 0, 10000, 0, false);
		}
		else
		{
			ABowling hitActor = Cast<ABowling>(Hit.GetActor());
			if (hitActor != nullptr)
			{
				hitActor.AddForce(ImpactVelocity * 0.8);
				hitActor.StopLifeTimeCounter = 0;
			}
		}
	}

	// UFUNCTION(BlueprintOverride)
	// void Destroyed()
	// {
	// 	Print("" + MovementComp.Velocity.Size(), 100);
	// }
}
