delegate void FBowlingHitDelegate(AActor OtherActor);

class ABowling : AActor
{
	default LifeSpan = 3.5;

	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;
	default Collider.SimulatePhysics = true;

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
	float BowlingDeaccel = 100;
	float DeaccelAddend = 0;

	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	float Attack = 10;

	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	EStatus Status = EStatus::Fire;

	FBowlingHitDelegate OnHit;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0, MaterialInstance);

		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (MovementComp.Velocity.SizeSquared() > 256)
		{
			MovementComp.Velocity -= MovementComp.Velocity.GetSafeNormal() * (BowlingDeaccel + DeaccelAddend) * DeltaSeconds;
		}
		else if (MovementComp.Velocity != FVector::ZeroVector)
		{
			MovementComp.Velocity = FVector::ZeroVector;
		}
	}

	void Fire(FVector Direction, float Force)
	{
		MovementComp.InitialSpeed = Force;
		MovementComp.Velocity *= Force;
		MovementComp.Activate();
		if (Status != EStatus::None)
		{
			EffectSystem.Activate();
		}
	}

	UFUNCTION()
	void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		// Print("Real: " + Hit.Location, 100);
		// Print("Real vector: " + MovementComp.Velocity, 100);
		OnHit.ExecuteIfBound(OtherActor);
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
}
