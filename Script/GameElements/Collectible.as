class ACollectible : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	USphereComponent Collider;

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent Mesh;
	default Mesh.CollisionEnabled = ECollisionEnabled::NoCollision;

	UPROPERTY(DefaultComponent)
	URotatingMovementComponent RotateMovement;
	default RotateMovement.bUpdateOnlyIfRendered = true;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent HomingMovement;
	default HomingMovement.bRotationFollowsVelocity = false;
	default HomingMovement.bIsHomingProjectile = true;
	default HomingMovement.InitialSpeed = 0;
	default HomingMovement.MaxSpeed = 5000;
	default HomingMovement.HomingAccelerationMagnitude = 2500;
	default HomingMovement.ProjectileGravityScale = 0;
	default HomingMovement.bConstrainToPlane = true;
	default HomingMovement.PlaneConstraintAxisSetting = EPlaneConstraintAxisSetting::Z;

	UPROPERTY(DefaultComponent, Attach = Mesh)
	UNiagaraComponent TrailVFX;
	default TrailVFX.bAutoActivate = false;

	UPROPERTY(DefaultComponent)
	UDropComponent DropComponent;

	UPROPERTY()
	float ReverseSpeed = 1000;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TrailVFX.SetActive(false);
		// SetTarget(Gameplay::GetPlayerPawn(0).RootComponent);
	}

	UFUNCTION()
	void SetTarget(USceneComponent NewTarget)
	{
		HomingMovement.SetHomingTargetComponent(NewTarget);
		HomingMovement.Velocity = (GetActorLocation() - Gameplay::GetPlayerPawn(0).GetActorLocation()).GetSafeNormal() * ReverseSpeed;
		TrailVFX.Activate();
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(TargetRC))
		{
			if (TargetRC.TargetType == ETargetType::Bowling && HomingMovement.GetHomingTargetComponent() == nullptr)
			{
				SetTarget(OtherActor.GetOwner().RootComponent);
				OnCollectibleOverlap(OtherActor);
			}
			else if (TargetRC.TargetType == ETargetType::Player)
			{
				OnCollectibleCollected(OtherActor);
				PostCollectedAction();
			}
		}
	}

	void OnCollectibleOverlap(AActor OtherActor)
	{
		DropComponent.EndEarly();
	}

	void OnCollectibleCollected(AActor OtherActor)
	{
	}

	void PostCollectedAction()
	{
		DestroyActor();
	}
};