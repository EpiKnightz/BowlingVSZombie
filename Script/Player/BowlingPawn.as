enum ETouchTarget
{
	Battlefield,
	Player
}

class ABowlingPawn : APawn
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;
	default Collider.SimulatePhysics = false;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent BodyMesh;
	default BodyMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default BodyMesh.ReceivesDecals = false;

	UPROPERTY(DefaultComponent, Attach = BodyMesh)
	USkeletalMeshComponent HeadMesh;
	default HeadMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default HeadMesh.ReceivesDecals = false;

	UPROPERTY(DefaultComponent, Attach = BodyMesh) // , AttachSocket = RightHand
	USkeletalMeshComponent AccessoryMesh;
	default AccessoryMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default AccessoryMesh.ReceivesDecals = false;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent WorldWidget;
	default WorldWidget.CollisionEnabled = ECollisionEnabled::NoCollision;
	default WorldWidget.ReceivesDecals = false;

	UPROPERTY(DefaultComponent)
	UEnhancedInputComponent InputComponent;

	UPROPERTY(DefaultComponent)
	UMovementResponseComponent MovementResponseComponent;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	UPROPERTY(DefaultComponent)
	UAttackResponseComponent AttackResponseComponent;

	UPROPERTY(DefaultComponent)
	UStatusResponseComponent StatusResponseComponent;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputMappingContext DefaultMappingContext;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction TouchAction;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction BackAction;

	UPROPERTY(BlueprintReadOnly, Category = Input)
	float CooldownPercent;

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

	FItemConfigsDT ItemsConfig;

	UPROPERTY()
	float BowlingPowerMark = 800;
	UPROPERTY()
	float BowlingPowerMultiplier = 0;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent ThrowSFX;

	ABowlingPlayerController PlayerController;
	FVector OriginalPos;

	int ComboCounter = 0;
	FIntDelegate DOnComboUpdate;
	UPROPERTY()
	float ComboExpireTime = 2;

	FBallDT CurrentBallData;

	ETouchTarget CurrentTouchTarget = ETouchTarget::Battlefield;

	float DamageBoost = 1;

	FVector PressLoc;

	UPROPERTY(DefaultComponent)
	UAbilitySystem AbilitySystem;

	UFCTweenBPActionFloat FloatTween;
	FFloatDelegate DOnCooldownUpdate;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		HeadMesh.SetLeaderPoseComponent(BodyMesh);
		AccessoryMesh.SetLeaderPoseComponent(BodyMesh);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Controller is nullptr in ConstructionScript(), but is valid in BeginPlay(), so this is the proper place to init this I guess.
		PlayerController = Cast<ABowlingPlayerController>(Controller);
		SetupPlayerInputComponent(InputComponent);
		AbilitySystem.RegisterAttrSet(UAttackAttrSet);
		AbilitySystem.RegisterAttrSet(UMovementAttrSet);
		AbilitySystem.Initialize(n"MoveSpeed", 500);

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

		DamageResponseComponent.Initialize(AbilitySystem);
		AttackResponseComponent.Initialize(AbilitySystem);
		StatusResponseComponent.Initialize(AbilitySystem);
		AbilitySystem.EOnPostSetCurrentValue.AddUFunction(this, n"OnPostSetCurrentValue");

		auto AttackBuffZone = Gameplay::GetActorOfClass(AAttackBuffZone);
		if (IsValid(AttackBuffZone))
		{
			SetGuideArrowTarget(AttackBuffZone.GetActorLocation());
		}
	}

	UFUNCTION()
	private void OnPostSetCurrentValue(FName AttrName, float Value)
	{
		if (AttrName == n"AttackCooldown")
		{
			if (FloatTween != nullptr)
			{
				if (FloatTween.GetTimeElapsed() >= Value)
				{
					FloatTween.Stop();
					FloatTween.ApplyEasing.Clear();
					SetCooldownPercent(1);
				}
				else
				{
					FloatTween.SetTimeMultiplier(FloatTween.GetTimeRemaining() / (Value - FloatTween.GetTimeElapsed()));
				}
			}
		}
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

	UFUNCTION(BlueprintCallable)
	void TouchTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		FHitResult outResult;
		TArray<EObjectTypeQuery> objectTypeArray;
		objectTypeArray.Add(EObjectTypeQuery::ReceiveInput);
		objectTypeArray.Add(EObjectTypeQuery::Pawn);
		FVector location = GetActorLocation();
		if (PlayerController.GetHitResultUnderFingerForObjects(ETouchIndex::Touch1, objectTypeArray, false, outResult))
		{
			if (outResult.Actor != this)
			{
				if (CooldownPercent >= 1)
				{
					BowlingDataTable.FindRow(ItemsConfig.BowlingID[Math::RandRange(0, ItemsConfig.BowlingID.Num() - 1)], CurrentBallData);
					PredictLine.ClearInstances();
					CurrentTouchTarget = ETouchTarget::Battlefield;
					PressLoc = outResult.Location;
					location.Z = 0;
					BowlingPowerMultiplier = Math::Clamp(PressLoc.Distance(location) / BowlingPowerMark, 0.2, 1);
					// Print("Touch " + bowlingPowerMultiplier, 100);
					SetActorRotation(FRotator(0, FRotator::MakeFromX(location - PressLoc).ZYaw, 0));
					DrawPredictLine();
				}
			}
			else
			{
				CurrentTouchTarget = ETouchTarget::Player;
				CalculateMovement(location, outResult.Location);
			}
		}
	}

	UFUNCTION(BlueprintCallable)
	void HoldTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		FHitResult outResult;
		TArray<EObjectTypeQuery> objectTypeArray;
		objectTypeArray.Add(EObjectTypeQuery::ReceiveInput);

		if (PlayerController.GetHitResultUnderFingerForObjects(ETouchIndex::Touch1, objectTypeArray, false, outResult))
		{
			FVector location = GetActorLocation();
			if (CurrentTouchTarget == ETouchTarget::Battlefield)
			{
				if (CooldownPercent >= 1)
				{

					PressLoc = outResult.Location;

					// location.Z = 0;
					float tempModifier = Math::Clamp(PressLoc.Distance(location) / BowlingPowerMark, 0.2, 1);
					float Yaw = FRotator::MakeFromX(location - PressLoc).ZYaw;

					if (!Math::IsNearlyEqual(Yaw, GetActorRotation().ZYaw) || !Math::IsNearlyEqual(BowlingPowerMultiplier, tempModifier))
					{
						BowlingPowerMultiplier = tempModifier;
						// Print("Hold " + bowlingPowerMultiplier, 100);
						SetActorRotation(FRotator(0, Yaw, 0));
						// SetGuideArrowTarget(PressLoc);
						DrawPredictLine();
					}
				}
			}
			else if (CurrentTouchTarget == ETouchTarget::Player)
			{
				CalculateMovement(location, outResult.Location);
			}
		}
	}

	UFUNCTION(BlueprintCallable)
	void ReleaseTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		if (CurrentTouchTarget == ETouchTarget::Battlefield)
		{
			if (CooldownPercent >= 1 && BowlingPowerMultiplier != 0)
			{
				ABowling SpawnedActor = Cast<ABowling>(SpawnActor(BowlingTemplate, GetActorLocation(), GetActorRotation()));
				CurrentBallData.Atk = CurrentBallData.Atk * DamageBoost;
				SpawnedActor.SetData(CurrentBallData);
				SpawnedActor.SetOwner(this);
				SpawnedActor.Fire(-GetActorForwardVector(), CurrentBallData.BowlingSpeed * BowlingPowerMultiplier);

				SpawnedActor.DOnHit.BindUFunction(this, n"OnHit");

				FMODBlueprint::PlayEvent2D(this, ThrowSFX, true);

				AbilitySystem.SetBaseValue(n"AttackCooldown", CurrentBallData.Cooldown);
				SetCooldownPercent(0);

				if (FloatTween != nullptr)
				{
					FloatTween.Stop();
					FloatTween.ApplyEasing.Clear();
					FloatTween.SetTimeMultiplier(1);
				}
				FloatTween = UFCTweenBPActionFloat::TweenFloat(0, 1, AbilitySystem.GetValue(n"AttackCooldown"), EFCEase::Linear);
				FloatTween.ApplyEasing.AddUFunction(this, n"SetCooldownPercent");
				FloatTween.Start();
			}
			PredictLine.ClearInstances();
			PressLoc = FVector::ZeroVector;
			BowlingPowerMultiplier = 0;
		}
		else if (CurrentTouchTarget == ETouchTarget::Player)
		{
		}
	}

	UFUNCTION(BlueprintCallable)
	void BackTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		Gameplay::OpenLevel(n"M_MainMenu");
	}

	void CalculateMovement(FVector currentLocation, FVector targetLocation)
	{
		float moveAmount = targetLocation.Y - currentLocation.Y;
		float newPosY = currentLocation.Y + Math::Sign(moveAmount) * Math::Clamp(Math::Abs(moveAmount), 0, AbilitySystem.GetValue(n"MoveSpeed") * Gameplay::GetWorldDeltaSeconds());
		SetActorLocation(FVector(currentLocation.X, Math::Clamp(newPosY, -400, 400), currentLocation.Z));
	}

	void SetGuideArrowTarget(FVector Target)
	{
		float Yaw = FRotator::MakeFromX(GetActorLocation() - Target).ZYaw;
		WorldWidget.SetWorldRotation(FRotator(90, 0, -Yaw));
	}

	UFUNCTION(BlueprintCallable)
	void DrawPredictLine()
	{
		PredictLine.ClearInstances();
		FPredictProjectilePathParams PredictProjectilePathParams;
		PredictProjectilePathParams.StartLocation = GetActorLocation();
		PredictProjectilePathParams.bTraceWithCollision = true;
		PredictProjectilePathParams.TraceChannel = ECollisionChannel::ECC_Pawn;
		FVector predictVector = -GetActorForwardVector() * CurrentBallData.BowlingSpeed * BowlingPowerMultiplier * 1.5;
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

			// Draw a seconde line for the bounce
			PredictProjectilePathParams.MaxSimTime = Math::Clamp(PredictSimTime * 0.8 - PredictProjectilePathResult.PathData[PredictProjectilePathResult.PathData.Num() - 1].Time, 0.2, PredictSimTime);
			PredictProjectilePathParams.LaunchVelocity = Math::GetReflectionVector(predictVector, PredictProjectilePathResult.HitResult.Normal) * 0.6;
			PredictProjectilePathParams.StartLocation = PredictProjectilePathResult.HitResult.Location + PredictProjectilePathParams.LaunchVelocity.GetSafeNormal();
			FPredictProjectilePathResult PredictProjectilePathResult2;
			Gameplay::Blueprint_PredictProjectilePath_Advanced(PredictProjectilePathParams, PredictProjectilePathResult2);
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

	UFUNCTION()
	void SetCooldownPercent(float32 NewValue)
	{
		CooldownPercent = NewValue;
		DOnCooldownUpdate.ExecuteIfBound(CooldownPercent);
	}

	UFUNCTION()
	void OnComboTrigger(int Change)
	{
		ComboCounter += Change;
		System::SetTimer(this, n"ComboExpired", ComboExpireTime, false);
		DOnComboUpdate.ExecuteIfBound(ComboCounter);
	}

	UFUNCTION()
	void ComboExpired()
	{
		ComboCounter = 0;
		DOnComboUpdate.ExecuteIfBound(ComboCounter);
	}

	UFUNCTION()
	void OnHit(AActor OtherActor)
	{
		auto targetRC = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(targetRC) && targetRC.TargetType == ETargetType::Zombie)
		{
			OnComboTrigger(1);
		}
	}

	UFUNCTION()
	void CoinComboHandler(int value)
	{
		OnComboTrigger(1);
	}

	UFUNCTION()
	void OnDamageBoost(float BoostPercentage)
	{
		DamageBoost = BoostPercentage;
	}
}
