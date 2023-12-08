class ABowlingPawn : APawn
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent BowlingMesh;

	UPROPERTY(DefaultComponent)
	UEnhancedInputComponent InputComponent;

	// UPROPERTY( DefaultComponent )
	// UProjectileMovementComponent MovementComp;
	// default MovementComp.bShouldBounce = true;
	// default MovementComp.ProjectileGravityScale = 0;
	// default MovementComp.AutoActivate = false;
	// default MovementComp.MaxSpeed = 1500;
	// default MovementComp.InitialSpeed = 2500;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputMappingContext DefaultMappingContext;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction TouchAction;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction BackAction;

	UPROPERTY(DefaultComponent)
	UInstancedStaticMeshComponent PredictLine;
	default PredictLine.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default PredictLine.SetCastShadow(false);

	UPROPERTY()
	TSubclassOf<ABowling> BowlingTemplate;

	UPROPERTY()
	float BowlingSpeed = 5000;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent ThrowSFX;

	ABowlingPlayerController PlayerController;
	FVector OriginalPos;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Controller is nullptr in ConstructionScript(), but is valid in BeginPlay(), so this is the proper place to init this I guess.
		PlayerController = Cast<ABowlingPlayerController>(Controller);
		// PlayerController.PushInputComponent(InputComponent); // Already connected to PlayerController for some reason. Don't do this or your events will fire twice.
		SetupPlayerInputComponent(InputComponent);

		// Add Input Mapping Context
		if (PlayerController != nullptr)
		{
			auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController.GetLocalPlayer());
			check(Subsystem != nullptr);
			if (Subsystem != nullptr)
			{
				Subsystem.AddMappingContext(DefaultMappingContext, 0, FModifyContextOptions());
			}
		}
		OriginalPos = GetActorLocation();
	}

	//////////////////////////////////////////////////////////////////////////// Input

	void SetupPlayerInputComponent(UEnhancedInputComponent EnhancedInputComponent)
	{
		// Set up action bindings
		// Pressed
		FEnhancedInputActionHandlerDynamicSignature PressTriggered;
		PressTriggered.BindUFunction(this, n"TouchTriggered");
		EnhancedInputComponent.BindAction(TouchAction, ETriggerEvent::Started, PressTriggered);

		// Hold
		FEnhancedInputActionHandlerDynamicSignature HoldTriggered;
		HoldTriggered.BindUFunction(this, n"HoldTriggered");
		EnhancedInputComponent.BindAction(TouchAction, ETriggerEvent::Triggered, HoldTriggered);

		// Release
		FEnhancedInputActionHandlerDynamicSignature ReleaseTriggered;
		ReleaseTriggered.BindUFunction(this, n"ReleaseTriggered");
		EnhancedInputComponent.BindAction(TouchAction, ETriggerEvent::Completed, ReleaseTriggered);

		FEnhancedInputActionHandlerDynamicSignature BackTriggered;
		BackTriggered.BindUFunction(this, n"BackTriggered");
		EnhancedInputComponent.BindAction(BackAction, ETriggerEvent::Completed, BackTriggered);
	}

	FVector2D PressLoc;

	UFUNCTION(BlueprintCallable)
	void TouchTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		PredictLine.ClearInstances();
		// MovementComp.SetActive(false);
		SetActorRotation(FRotator(0, 0, 0));
		// bool bIsPressed;
		// PlayerController.GetInputTouchState(ETouchIndex::Touch1, PressX, PressY, bIsPressed);
		PlayerController.ProjectWorldLocationToScreen(GetActorLocation(), PressLoc);
		// Print("Touch triggered " + PressLoc.X + "|" + PressLoc.Y );
		FPredictProjectilePathParams PredictProjectilePathParams;
		PredictProjectilePathParams.StartLocation = GetActorLocation();
		PredictProjectilePathParams.TraceChannel = ECollisionChannel::ECC_Pawn;
		PredictProjectilePathParams.LaunchVelocity = -GetActorForwardVector() * 15000;
		PredictProjectilePathParams.OverrideGravityZ = 0.001f;
		PredictProjectilePathParams.ProjectileRadius = 1;
		PredictProjectilePathParams.MaxSimTime = 1.15f;
		PredictProjectilePathParams.bTraceWithCollision = false;
		TArray<TObjectPtr<AActor>> ignoreList;
		ignoreList.Add(this);
		PredictProjectilePathParams.ActorsToIgnore = ignoreList;
		FPredictProjectilePathResult PredictProjectilePathResult;
		Gameplay::Blueprint_PredictProjectilePath_Advanced(PredictProjectilePathParams, PredictProjectilePathResult);

		for (int i = 2; i < PredictProjectilePathResult.PathData.Num() - 1; i++)
		{
			FTransform transform = FTransform::Identity;
			transform.SetLocation(PredictProjectilePathResult.PathData[i].Location);
			transform.SetScale3D(FVector(1, 1, 1));
			PredictLine.AddInstance(transform);
		}

		if (PredictProjectilePathResult.HitResult.GetActor() != nullptr)
		{
			FTransform transform = FTransform::Identity;
			transform.SetLocation(PredictProjectilePathResult.HitResult.Location);
			transform.SetScale3D(FVector(1, 1, 1));
			PredictLine.AddInstance(transform);
		}
	}

	UFUNCTION(BlueprintCallable)
	void HoldTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{

		// MaterialInstance.SetVectorParameterValue(FName("Base Color"), FLinearColor(0,1,0));
		bool bIsPressed;
		float32 HoldX = 0, HoldY = 0;
		PlayerController.GetInputTouchState(ETouchIndex::Touch1, HoldX, HoldY, bIsPressed);
		if ((HoldY - PressLoc.Y) < -0.001f)
		{
			HoldY = float32(HoldY - PressLoc.Y);
		}
		else
		{
			HoldY = -0.001f;
		}
		float Yaw = Math::RadiansToDegrees(Math::Atan((PressLoc.X - HoldX) / HoldY));
		float Angle = Math::Abs(Yaw);
		if (Angle <= 50)
		{
			Yaw = Yaw * 0.65f;
		}
		else if (Angle <= 75)
		{
			Yaw = Yaw * Math::Lerp(0.65f, 0.9f, (Angle - 50) / 25);
		}
		else
		{
			Yaw = Yaw * Math::Lerp(0.9f, 1, (Angle - 75) / 15);
		}
		SetActorRotation(FRotator(0, Yaw, 0));
		// SetActorLocation(OriginalPos.X - (PressX-HoldX)/100,OriginalPos.Y - (),OriginalPos.Z);
	}

	UFUNCTION(BlueprintCallable)
	void ReleaseTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		ABowling SpawnedActor = Cast<ABowling>(SpawnActor(BowlingTemplate, GetActorLocation(), GetActorRotation()));
		SpawnedActor.Fire(-GetActorForwardVector(), BowlingSpeed * 5000);

		FMODBlueprint::PlayEvent2D(this, ThrowSFX, true);

		PredictLine.ClearInstances();
		PressLoc = FVector2D::ZeroVector;
	}

	UFUNCTION(BlueprintCallable)
	void BackTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		Gameplay::OpenLevel(FName("MainMenu"));
	}
}
