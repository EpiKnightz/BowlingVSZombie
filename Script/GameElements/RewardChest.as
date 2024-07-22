class ARewardChest : ACollectible
{
	UPROPERTY(DefaultComponent, Attach = Collider)
	USkeletalMeshComponent RewardBody;

	default TrailVFX.bAutoActivate = true;
	default HomingMovement.bConstrainToPlane = false;
	default HomingMovement.MaxSpeed = 350;
	default HomingMovement.HomingAccelerationMagnitude = 1000;

	FVoidDelegate DOnRewardCollected;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		Mesh.AttachToComponent(RewardBody, n"HingeSocket");
		TrailVFX.AttachToComponent(RewardBody);
	}

	UFUNCTION(BlueprintOverride, meta = (NoSuperCall))
	void BeginPlay()
	{
		// Mesh.AttachToComponent(RewardBody, n"HingeSocket");
	}

	void SetTarget(USceneComponent NewTarget) override
	{
		Print("" + NewTarget.GetName() + " " + NewTarget.GetWorldLocation());
		Super::SetTarget(NewTarget);
	}

	void OnCollectibleCollected(AActor OtherActor) override
	{
		HomingMovement.MaxSpeed = 150;
		HomingMovement.HomingAccelerationMagnitude = 450;
		RewardBody.Play(false);
		// DOnRewardCollected.ExecuteIfBound();
	}

	// Leave empty so don't destroy when collected
	void PostCollectedAction() override
	{
	}
};