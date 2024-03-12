delegate void FComboUpdateDelegate(int NewValue);
class ABowlingPawn : APawn
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent BowlingMesh;

	UPROPERTY(DefaultComponent)
	UEnhancedInputComponent InputComponent;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputMappingContext DefaultMappingContext;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction TouchAction;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction BackAction;

	UPROPERTY(BlueprintReadWrite, Category = Input)
	float TouchCooldown = 1;
	float currentTouchCooldown = -1;
	UPROPERTY(BlueprintReadOnly, Category = Input)
	float CooldownPercent = 1;

	UPROPERTY(DefaultComponent)
	UInstancedStaticMeshComponent PredictLine;
	default PredictLine.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default PredictLine.SetCastShadow(false);
	UPROPERTY()
	float PredictSimTime = 1;

	UPROPERTY()
	TSubclassOf<ABowling> BowlingTemplate;

	UPROPERTY(BlueprintReadWrite)
	UDataTable BowlingDataTable;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ItemsConfigDT;
	TArray<FItemsConfigDT> ItemsConfig;

	UPROPERTY()
	float BowlingSpeed = 1500;
	UPROPERTY()
	float BowlingPowerMark = 1500;
	UPROPERTY()
	float bowlingPowerMultiplier = 0;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent ThrowSFX;

	ABowlingPlayerController PlayerController;
	FVector OriginalPos;

	int ComboCounter = 0;
	FComboUpdateDelegate ComboUpdateDelegate;
	UPROPERTY()
	float ComboExpireTime = 2;

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

		ItemsConfigDT.GetAllRows(ItemsConfig);
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

	FVector PressLoc;

	UFUNCTION(BlueprintCallable)
	void TouchTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		if (currentTouchCooldown <= 0)
		{
			PredictLine.ClearInstances();
			FHitResult outResult;
			TArray<EObjectTypeQuery> objectTypeArray;
			objectTypeArray.Add(EObjectTypeQuery::ReceiveInput);
			if (PlayerController.GetHitResultUnderFingerForObjects(ETouchIndex::Touch1, objectTypeArray, false, outResult))
			{
				PressLoc = outResult.Location;
				FVector location = GetActorLocation();
				location.Z = 0;
				bowlingPowerMultiplier = Math::Clamp(PressLoc.Distance(location) / BowlingPowerMark, 0.2, 1);
				// Print("Touch " + bowlingPowerMultiplier, 100);
				SetActorRotation(FRotator(0, FRotator::MakeFromX(location - PressLoc).Yaw, 0));
				DrawPredictLine();
			}
		}
	}

	FString DebugTxt;

	UFUNCTION(BlueprintCallable)
	void DrawPredictLine()
	{
		PredictLine.ClearInstances();
		FPredictProjectilePathParams PredictProjectilePathParams;
		PredictProjectilePathParams.StartLocation = GetActorLocation();
		PredictProjectilePathParams.bTraceWithCollision = true;
		PredictProjectilePathParams.TraceChannel = ECollisionChannel::ECC_Pawn;
		FVector predictVector = -GetActorForwardVector() * BowlingSpeed * bowlingPowerMultiplier * 1.5;
		PredictProjectilePathParams.LaunchVelocity = predictVector;
		PredictProjectilePathParams.OverrideGravityZ = 0.0001f;
		PredictProjectilePathParams.ProjectileRadius = 36;
		PredictProjectilePathParams.MaxSimTime = PredictSimTime;
		// PredictProjectilePathParams.DrawDebugType = EDrawDebugTrace::ForDuration;
		// PredictProjectilePathParams.DrawDebugTime = 5;
		//  PredictProjectilePathParams.bTraceWithCollision = false;
		TArray<TObjectPtr<AActor>> ignoreList;
		ignoreList.Add(this);
		PredictProjectilePathParams.ActorsToIgnore = ignoreList;
		FPredictProjectilePathResult PredictProjectilePathResult;
		Gameplay::Blueprint_PredictProjectilePath_Advanced(PredictProjectilePathParams, PredictProjectilePathResult);

		for (int i = 1; i < PredictProjectilePathResult.PathData.Num() - 1; i++)
		{
			FTransform transform = FTransform::Identity;
			transform.SetLocation(PredictProjectilePathResult.PathData[i].Location);
			transform.SetScale3D(FVector(0.15f));
			PredictLine.AddInstance(transform);
		}

		if (PredictProjectilePathResult.HitResult.GetActor() != nullptr && PredictProjectilePathResult.HitResult.Component.GetCollisionObjectType() == ECollisionChannel::ECC_WorldStatic)
		{
			FTransform transform = FTransform::Identity;
			transform.SetLocation(PredictProjectilePathResult.HitResult.Location);
			transform.SetScale3D(FVector(0.25f));
			PredictLine.AddInstance(transform);

			// Print("Predict: " + PredictProjectilePathResult.HitResult.Location, 100);

			// Draw a seconde line for the bounce
			PredictProjectilePathParams.MaxSimTime = Math::Clamp(PredictSimTime * 0.8 - PredictProjectilePathResult.PathData[PredictProjectilePathResult.PathData.Num() - 1].Time, 0.2, PredictSimTime);
			PredictProjectilePathParams.LaunchVelocity = Math::GetReflectionVector(predictVector, PredictProjectilePathResult.HitResult.Normal) * 0.6;
			PredictProjectilePathParams.StartLocation = PredictProjectilePathResult.HitResult.Location + PredictProjectilePathParams.LaunchVelocity.GetSafeNormal();
			// Print("Predict velocity: " + PredictProjectilePathParams.LaunchVelocity, 100);
			FPredictProjectilePathResult PredictProjectilePathResult2;
			// PredictProjectilePathParams.ActorsToIgnore.Add(PredictProjectilePathResult.HitResult.GetActor());
			Gameplay::Blueprint_PredictProjectilePath_Advanced(PredictProjectilePathParams, PredictProjectilePathResult2);
			// FString tmp = "Line " + PredictProjectilePathResult2.PathData.Num() + " | " + PredictProjectilePathParams.LaunchVelocity + " | " + PredictProjectilePathParams.MaxSimTime + " | " + PredictProjectilePathResult2.HitResult.GetActor().ActorNameOrLabel;
			// if (DebugTxt != tmp)
			// {
			// 	DebugTxt = tmp;
			// 	Print(DebugTxt, 100);
			// }
			if (PredictProjectilePathResult2.PathData.Num() > 1)
			{
				for (int j = 1; j < PredictProjectilePathResult2.PathData.Num() - 1; j++)
				{
					FTransform transform2 = FTransform::Identity;
					transform2.SetLocation(PredictProjectilePathResult2.PathData[j].Location);
					transform2.SetScale3D(FVector(0.15f));
					PredictLine.AddInstance(transform2);
				}
			}
		}
	}

	UFUNCTION(BlueprintCallable)
	void HoldTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		if (currentTouchCooldown <= 0)
		{
			FHitResult outResult;
			TArray<EObjectTypeQuery> objectTypeArray;
			objectTypeArray.Add(EObjectTypeQuery::ReceiveInput);
			if (PlayerController.GetHitResultUnderFingerForObjects(ETouchIndex::Touch1, objectTypeArray, false, outResult))
			{
				PressLoc = outResult.Location;
				FVector location = GetActorLocation();
				location.Z = 0;
				float tempModifier = Math::Clamp(PressLoc.Distance(location) / BowlingPowerMark, 0.2, 1);
				float Yaw = FRotator::MakeFromX(location - PressLoc).Yaw;

				if (!Math::IsNearlyEqual(Yaw, GetActorRotation().Yaw) || !Math::IsNearlyEqual(bowlingPowerMultiplier, tempModifier))
				{
					bowlingPowerMultiplier = tempModifier;
					// Print("Hold " + bowlingPowerMultiplier, 100);
					SetActorRotation(FRotator(0, Yaw, 0));
					DrawPredictLine();
				}
			}
		}
	}

	UFUNCTION(BlueprintCallable)
	void ReleaseTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		if (currentTouchCooldown <= 0 && bowlingPowerMultiplier != 0)
		{
			FBallDT Row;
			BowlingDataTable.FindRow(ItemsConfig[0].BowlingID[Math::RandRange(0, ItemsConfig[0].BowlingID.Num() - 1)], Row);

			ABowling SpawnedActor = Cast<ABowling>(SpawnActor(BowlingTemplate, GetActorLocation(), GetActorRotation()));
			SpawnedActor.SetData(Row);
			// Print("" + bowlingPowerMultiplier, 100);
			SpawnedActor.Fire(-GetActorForwardVector(), BowlingSpeed * bowlingPowerMultiplier);

			SpawnedActor.OnHit.BindUFunction(this, n"OnHit");

			FMODBlueprint::PlayEvent2D(this, ThrowSFX, true);
			currentTouchCooldown = TouchCooldown;
		}
		PredictLine.ClearInstances();
		PressLoc = FVector::ZeroVector;
		bowlingPowerMultiplier = 0;
	}

	UFUNCTION(BlueprintCallable)
	void BackTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		Gameplay::OpenLevel(n"M_MainMenu");
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (currentTouchCooldown > 0)
		{
			currentTouchCooldown -= DeltaSeconds;
			CooldownPercent = Math::Clamp(1 - (currentTouchCooldown / TouchCooldown), 0, 1);
		}
	}

	UFUNCTION()
	void OnComboTrigger(int Change)
	{
		ComboCounter += Change;
		System::SetTimer(this, n"ComboExpired", ComboExpireTime, false);
		ComboUpdateDelegate.ExecuteIfBound(ComboCounter);
	}

	UFUNCTION()
	void ComboExpired()
	{
		ComboCounter = 0;
		ComboUpdateDelegate.ExecuteIfBound(ComboCounter);
	}

	UFUNCTION()
	void OnHit(AActor OtherActor)
	{
		AZombie zomb = Cast<AZombie>(OtherActor);
		if (zomb != nullptr)
		{
			OnComboTrigger(1);
		}
	}
}
