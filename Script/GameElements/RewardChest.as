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
		ACollectible::SetTarget(NewTarget);
	}

	void OnCollectibleCollected(AActor OtherActor) override
	{
		HomingMovement.MaxSpeed = 150;
		HomingMovement.HomingAccelerationMagnitude = 450;
		RotateMovement.RotationRate = FRotator(0, 90, 0);
		RewardBody.Play(false);
		System::SetTimer(this, n"OnRewardOpen", 2, false);
	}

	UFUNCTION()
	private void OnRewardOpen()
	{
		HomingMovement.MaxSpeed = 150;
		HomingMovement.HomingAccelerationMagnitude = 300;
		RotateMovement.RotationRate = FRotator(0, 0, 0);
		SetActorRotation(FRotator(0, 90, 0));
		DOnRewardCollected.ExecuteIfBound();
	}

	// Leave empty so don't destroy when collected
	void PostCollectedAction() override
	{
	}
};