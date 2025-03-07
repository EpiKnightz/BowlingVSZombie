const FRotator BASE_ROTATION_RATE = FRotator(0.4, 0, 0);
const float BOUNCE_ROTATION_RATE_MULTIPLIER = 0.7;
const float ADD_FORCE_ROTATION_RATE_MULTIPLIER = 0.5;
const float DEACCEL_ROTATION_RATE_MULTIPLIER = 0.975;

class ABowling : AProjectile
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;
	default Collider.SimulatePhysics = false;
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent BowlingMesh;
	default BowlingMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent, Attach = Collider)
	UNiagaraComponent EffectSystem;
	default EffectSystem.Activate(false);
	default EffectSystem.AutoActivate = false;

	UPROPERTY(BlueprintReadOnly)
	UMaterialInstanceDynamic MaterialInstance;

	default MovementComp.bShouldBounce = true;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.AutoActivate = false;
	default MovementComp.MaxSpeed = 10000;
	default MovementComp.bConstrainToPlane = true;
	default MovementComp.PlaneConstraintAxisSetting = EPlaneConstraintAxisSetting::UseGlobalPhysicsSetting;
	default MovementComp.PlaneConstraintNormal = FVector(0, 0, 1);
	default MovementComp.Velocity = FVector(-1, 0, 0);
	default MovementComp.Bounciness = 0.8;

	UPROPERTY(DefaultComponent)
	URotatingMovementComponent RotatingComp;
	default RotatingComp.RotationRate = BASE_ROTATION_RATE;
	default RotatingComp.bUpdateOnlyIfRendered = true;

	UPROPERTY(DefaultComponent)
	UMovementResponseComponent MovementResponseComponent;

	UPROPERTY(DefaultComponent)
	UMultiplierResponseComponent MultiplierResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Bowling;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent WorldWidget;
	UUIMultiplierText MultiplierText;

	FActorEvent EOnHit;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent HitSFX;

	UPROPERTY(DefaultComponent)
	ULiteAbilitySystem AbilitySystem;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0, MaterialInstance);

		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");

		AbilitySystem.RegisterAttrSet(UMovementAttrSet);
		AbilitySystem.SetBaseValue(MovementAttrSet::Accel, 0);
		AbilitySystem.RegisterAttrSet(UMultiplierBounceAttrSet);

		MovementResponseComponent.Initialize(AbilitySystem);
		MovementResponseComponent.EOnPreAddForceCue.AddUFunction(this, n"OnPreAddForceCue");
		MovementResponseComponent.EOnBounceCue.AddUFunction(this, n"OnBounceCue");
		MovementResponseComponent.DOnStopTimeReached.BindUFunction(this, n"K2_DestroyActor");
		MovementResponseComponent.EOnStopCue.AddUFunction(this, n"OnStopCue");
		MovementResponseComponent.EOnDeaccelTick.AddUFunction(this, n"OnDeaccelTick");

		MultiplierResponseComponent.Initialize(AbilitySystem);
		MultiplierText = Cast<UUIMultiplierText>(WorldWidget.GetWidget());
		if (!IsValid(MultiplierText))
		{
			PrintError("MultiplierText is invalid");
		}
		else
		{
			MultiplierResponseComponent.EOnAddMultiplierCue.AddUFunction(MultiplierText, n"SetMultiplierCountText");
		}
	}

	UFUNCTION()
	void SetData(FBallDT Data)
	{
		ProjectileDataComp.ProjectileData = Data;
		BowlingMesh.StaticMesh = Data.BowlingMesh;
		if (IsValid(Data.StatusVFX))
		{
			EffectSystem.Asset = Data.StatusVFX;
			EffectSystem.Activate();
		}

		RotatingComp.RotationRate = BASE_ROTATION_RATE * Data.BowlingSpeed;

		SetPiercable(ProjectileDataComp.ProjectileData.EffectTags.HasTagExact(GameplayTags::Status_Neutral_Piercing));
	}

	UFUNCTION()
	void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		EOnHit.Broadcast(OtherActor);
		if (TargetResponseComponent.IsTargetable(OtherActor))
		{
			auto DamageResponse = UDamageResponseComponent::Get(OtherActor);
			if (IsValid(DamageResponse))
			{
				float Damage = TargetResponseComponent.IsSameTeam(OtherActor) ?
								   0 :
								   MultiplierResponseComponent.DCaluclateMultiplier.Execute(ProjectileDataComp.ProjectileData.Atk);
				// This is because the atk should already been buff/debuff at spawned time.
				DamageResponse.DOnTakeHit.ExecuteIfBound(Damage);
				if (Damage > 0)
				{
					auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
					if (IsValid(StatusResponse))
					{
						StatusResponse.DOnApplyStatus.ExecuteIfBound(ProjectileDataComp.ProjectileData.EffectTags);
					}
				}
			}
		}
		// TODO: Change to other sfx
		// FMODBlueprint::PlayEvent2D(this, HitSFX, true);
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (TargetResponseComponent.IsPierceable(OtherActor))
		{
			MovementResponseComponent.ActorPierce(OtherActor);
		}
		ActorBeginHit(nullptr, OtherActor, nullptr, FVector(0, 0, 0), FHitResult());
	}

	UFUNCTION()
	void SetPiercable(bool bPierce)
	{
		Collider.SetCollisionResponseToChannel(ECollisionChannel::Enemy,
											   bPierce ? ECollisionResponse::ECR_Overlap : ECollisionResponse::ECR_Block);
		Collider.SetCollisionResponseToChannel(ECollisionChannel::Survivor,
											   bPierce ? ECollisionResponse::ECR_Overlap : ECollisionResponse::ECR_Block);
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Visual Cues:

	UFUNCTION()
	private void OnInitForceCue()
	{
		if (!ProjectileDataComp.ProjectileData.EffectTags.IsEmpty())
		{
			EffectSystem.Activate();
		}
	}

	UFUNCTION()
	private void OnPreAddForceCue(FVector Value)
	{
		MovementResponseComponent.StopTimeCounter = 0;
		RotatingComp.RotationRate += FRotator(-Value.X, Value.Z, -Value.Y) * ADD_FORCE_ROTATION_RATE_MULTIPLIER;
	}

	UFUNCTION()
	private void OnDeaccelTick()
	{
		RotatingComp.RotationRate *= DEACCEL_ROTATION_RATE_MULTIPLIER;
	}

	UFUNCTION()
	void OnBounceCue(const FHitResult Hit)
	{
		if (Hit.GetComponent().ComponentHasTag(n"Boundary"))
		{
			Gameplay::PlayWorldCameraShake(ShakeStyle, GetActorLocation(), 0, 10000, 0, false);
		}
		RotatingComp.RotationRate *= BOUNCE_ROTATION_RATE_MULTIPLIER;
	}

	UFUNCTION()
	private void OnStopCue()
	{
		RotatingComp.RotationRate = FRotator::ZeroRotator;
	}
}