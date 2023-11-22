class ABowlingPawn : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent BowlingMesh;

    UPROPERTY(DefaultComponent)
	UEnhancedInputComponent InputComponent;

    UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputMappingContext DefaultMappingContext;

	UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputAction TouchAction;

	UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputAction HoldAction;

	UPROPERTY( BlueprintReadOnly, Category=Input, meta = (AllowPrivateAccess = "true"))
	UInputAction ReleaseAction;

	UPROPERTY( BlueprintReadOnly )
	UMaterialInstanceDynamic MaterialInstance;

    UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Controller is nullptr in ConstructionScript(), but is valid in BeginPlay(), so this is the proper place to init this I guess.
		auto PlayerController = Cast<APlayerController>(Controller);
        // PlayerController.PushInputComponent(InputComponent); // Already connected to PlayerController for some reason. Don't do this or your events will fire twice.
		SetupPlayerInputComponent(InputComponent);

		//Add Input Mapping Context
		if (PlayerController != nullptr)
		{
			auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController.GetLocalPlayer());
			check(Subsystem != nullptr);
			if (Subsystem != nullptr)
			{
				Subsystem.AddMappingContext(DefaultMappingContext, 0, FModifyContextOptions());
			}
		}
		MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0,MaterialInstance);

	}

    	//////////////////////////////////////////////////////////////////////////// Input

	void SetupPlayerInputComponent(UEnhancedInputComponent EnhancedInputComponent)
	{
		// Set up action bindings
		// Pressed
		FEnhancedInputActionHandlerDynamicSignature PressTriggered;
		PressTriggered.BindUFunction(this, n"TouchTriggered");
		EnhancedInputComponent.BindAction(TouchAction, ETriggerEvent::Triggered, PressTriggered);

		// Hold
		FEnhancedInputActionHandlerDynamicSignature HoldTriggered;
		HoldTriggered.BindUFunction(this, n"HoldTriggered");
		EnhancedInputComponent.BindAction(HoldAction, ETriggerEvent::Triggered, HoldTriggered);

		// Release
		FEnhancedInputActionHandlerDynamicSignature ReleaseTriggered;
		ReleaseTriggered.BindUFunction(this, n"ReleaseTriggered");
		EnhancedInputComponent.BindAction(ReleaseAction, ETriggerEvent::Triggered, ReleaseTriggered);
	}

    UFUNCTION(BlueprintCallable)
    void TouchTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
        Print("Touch triggered");
		MaterialInstance.SetVectorParameterValue(FName("Base Color"), FLinearColor(1,0,0));
    }

	UFUNCTION(BlueprintCallable)
    void HoldTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
        Print("Hold triggered");
		MaterialInstance.SetVectorParameterValue(FName("Base Color"), FLinearColor(0,1,0));
    }

	UFUNCTION(BlueprintCallable)
    void ReleaseTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
        Print("Release triggered");
		MaterialInstance.SetVectorParameterValue(FName("Base Color"), FLinearColor(1,1,1));
    }
}
