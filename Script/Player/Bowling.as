class ABowling : AActor
{
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
	default MovementComp.MaxSpeed = 15000;
	default MovementComp.bConstrainToPlane = true;
	default MovementComp.PlaneConstraintAxisSetting = EPlaneConstraintAxisSetting::UseGlobalPhysicsSetting;
	default MovementComp.PlaneConstraintNormal = FVector(0, 0, 1);
	default MovementComp.Velocity = FVector(-1, 0, 0);
	default MovementComp.Bounciness = 0.8;

	UPROPERTY(DefaultComponent)
	UMovementResponseComponent MovementResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Player;

	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	FBallDT BallData;

	FActorDelegate DOnHit;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(DefaultComponent)
	UAbilitySystem AbilitySystem;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0, MaterialInstance);

		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");

		AbilitySystem.RegisterAttrSet(UMovementAttrSet);
		AbilitySystem.SetBaseValue(n"Accel", 0);

		MovementResponseComponent.Initialize(AbilitySystem);
		MovementResponseComponent.EOnPreAddForceCue.AddUFunction(this, n"OnPreAddForceCue");
		MovementResponseComponent.EOnBounceCue.AddUFunction(this, n"OnBounceCue");
		MovementResponseComponent.DOnStopTimeReached.BindUFunction(this, n"K2_DestroyActor");
	}

	UFUNCTION()
	void SetData(FBallDT Data)
	{
		BallData = Data;
		BowlingMesh.StaticMesh = BallData.BowlingMesh;
		EffectSystem.Asset = Data.StatusVFX;
	}

	UFUNCTION()
	void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		DOnHit.ExecuteIfBound(OtherActor);
		if (TargetResponseComponent.IsTargetable(OtherActor))
		{
			auto DamageResponse = UDamageResponseComponent::Get(OtherActor);
			if (IsValid(DamageResponse))
			{
				DamageResponse.TakeHit(BallData.Atk);
				auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(BallData.EffectTags);
				}
			}
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Visual Cues:

	UFUNCTION()
	private void OnInitForceCue()
	{
		if (!BallData.EffectTags.IsEmpty())
		{
			EffectSystem.Activate();
		}
	}

	UFUNCTION()
	private void OnPreAddForceCue(FVector Value)
	{
		MovementResponseComponent.StopTimeCounter = 0;
	}

	UFUNCTION()
	void OnBounceCue(const FHitResult Hit)
	{
		if (Hit.GetComponent().ComponentHasTag(n"Boundary"))
		{
			Gameplay::PlayWorldCameraShake(ShakeStyle, GetActorLocation(), 0, 10000, 0, false);
		}
	}
}