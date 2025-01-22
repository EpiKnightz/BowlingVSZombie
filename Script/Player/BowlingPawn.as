enum ETouchTarget
{
	Battlefield,
	Player,
	None
}

const FLinearColor THROWABLE_COLOR = FLinearColor(0.002428, 0.138432, 0.57758, 1);
const FLinearColor UNTHROWABLE_COLOR = FLinearColor(1, 0, 0, 1);

class ABowlingPawn : APawn
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;
	default Collider.SimulatePhysics = false;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent HamsterMesh;
	default HamsterMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default HamsterMesh.ReceivesDecals = false;

	UCustomAnimInst AnimateInst;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage AttackAnim;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent WorldWidget;
	default WorldWidget.CollisionEnabled = ECollisionEnabled::NoCollision;
	default WorldWidget.ReceivesDecals = false;
	default WorldWidget.SetHiddenInGame(true);
	default WorldWidget.TickMode = ETickMode::Automatic;

	UPROPERTY(DefaultComponent)
	UEnhancedInputComponent InputComponent;

	UPROPERTY(DefaultComponent)
	UMovementResponseComponent MovementResponseComponent;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default MovementComp.bShouldBounce = false;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.AutoActivate = false;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	UPROPERTY(DefaultComponent)
	UAttackResponseComponent AttackResponseComponent;

	UPROPERTY(DefaultComponent)
	UStatusResponseComponent StatusResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Player;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction TouchAction;

	UPROPERTY(BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	UInputAction BackAction;

	UPROPERTY(BlueprintReadOnly, Category = Input)
	float HoldThreshold = 0.5;
	bool bIsHoldTriggered = false;

	UPROPERTY(BlueprintReadOnly, Category = Input)
	float CooldownPercent;

	UPROPERTY(DefaultComponent)
	UInstancedStaticMeshComponent PredictLine;
	default PredictLine.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default PredictLine.SetCastShadow(false);

	UMaterialInstanceDynamic PredictLineMaterial;

	UPROPERTY()
	float PredictSimTime = 1;

	UPROPERTY()
	TSubclassOf<ABowling> BowlingTemplate;

	UPROPERTY(BlueprintReadWrite)
	UDataTable BowlingDataTable;
	TMap<FGameplayTag, FBallDT> BowlingsMap;

	FItemPoolConfigDT ItemPoolConfig;

	UPROPERTY()
	float BowlingPowerMark = 800;
	UPROPERTY()
	float BowlingPowerMultiplier = 0;

	UPROPERTY()
	float MinSlowTime = 0.25;
	UPROPERTY()
	float MaxSlowTime = 0.75;
	UPROPERTY()
	float MaxSlowTimeDistance = 800;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent ThrowSFX;

	ABowlingPlayerController PlayerController;
	FVector OriginalPos;

	int ComboCounter = 0;
	FIntDelegate DOnComboUpdate;
	UPROPERTY()
	float ComboExpireTime = 2;

	FBallDT CurrentBallData;

	ETouchTarget CurrentTouchTarget = ETouchTarget::None;

	FVector PressLoc;
	bool bIsAimable;

	UPROPERTY(DefaultComponent)
	ULiteAbilitySystem AbilitySystem;

	UFCTweenBPActionFloat FloatTween;
	FFloatEvent EOnCooldownUpdate;
	FVectorDelegate DOnChangeGuideArrowTarget;
	// FVoidDelegate DOnHideArrow;

	FActorVectorEvent EOnTouchTriggered;
	FActorVectorEvent EOnHoldTriggered;
	FActorVectorEvent EOnTouchHold;
	FActorVectorEvent EOnTouchReleased;
	FActorVectorEvent EOnHoldReleased;
	FBowlingEvent EOnBowlingSpawned;
	FBoolDelegate DSetBowlingAimable;
	FFloatDelegate DBoostAttentionPercentage;

	/////////////////////////////////////////
	// Setup
	/////////////////////////////////////////

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Controller is nullptr in ConstructionScript(), but is valid in BeginPlay(), so this is the proper place to init this I guess.
		PlayerController = Cast<ABowlingPlayerController>(Controller);
		SetupPlayerInputComponent(InputComponent);
		AbilitySystem.RegisterAttrSet(UAttackAttrSet);
		AbilitySystem.RegisterAttrSet(UMovementAttrSet);
		AbilitySystem.Initialize(n"MoveSpeed", 500);
		AbilitySystem.Initialize(n"Accel", 500);

		AnimateInst = Cast<UCustomAnimInst>(HamsterMesh.GetAnimInstance());
		OriginalPos = GetActorLocation();

		DamageResponseComponent.Initialize(AbilitySystem);
		AttackResponseComponent.Initialize(AbilitySystem);
		AttackResponseComponent.EOnAnimHitNotify.AddUFunction(this, n"OnAnimHitNotify");
		AttackResponseComponent.DGetAttackLocation.BindUFunction(this, n"GetAttackLocation");
		AttackResponseComponent.DGetAttackRotation.BindUFunction(this, n"GetAttackRotation");

		StatusResponseComponent.Initialize(AbilitySystem);
		MovementResponseComponent.Initialize(AbilitySystem);
		TargetResponseComponent.Initialize(AbilitySystem);
		// Temporary
		AbilitySystem.EOnPostSetCurrentValue.AddUFunction(this, n"OnPostSetCurrentValue");

		DOnChangeGuideArrowTarget.BindUFunction(this, n"SetGuideArrowTarget");
		// DOnHideArrow.BindUFunction(this, n"HideGuideArrow");
		DSetBowlingAimable.BindUFunction(this, n"SetBowlingAimable");
		SetBowlingAimable(true);

		PredictLineMaterial = Material::CreateDynamicMaterialInstance(PredictLine.GetMaterial(0));
		PredictLine.SetMaterial(0, PredictLineMaterial);
		EOnCooldownUpdate.AddUFunction(this, n"SetPredictLineColor");

		// Load bowling data
		TArray<FBallDT> BowlingsArray;
		BowlingDataTable.GetAllRows(BowlingsArray);
		for (FBallDT Bowling : BowlingsArray)
		{
			BowlingsMap.Add(Bowling.BowlingID, Bowling);
		}
	}

	UFUNCTION()
	FBallDT GetBowlingData(FGameplayTag BallID)
	{
		FBallDT BallData;
		if (BowlingsMap.Find(BallID, BallData) != false)
		{
			return BallData;
		}
		else
		{
			PrintError("GetBowlingData: BowlingID not found");
			return BallData;
		}
	}

	UFUNCTION()
	private void OnPostSetCurrentValue(FName AttrName, float Value)
	{
		if (AttrName == n"AttackCooldown")
		{
			if (IsValid(FloatTween) && FloatTween.IsValid())
			{
				if (FloatTween.GetTimeElapsed() >= Value)
				{
					ClearTween(true);
					SetCooldownPercent(1);
				}
				else
				{
					FloatTween.SetTimeMultiplier(FloatTween.GetTimeRemaining() / (Value - FloatTween.GetTimeElapsed()));
				}
				AnimateInst.AnimPlayRate = Value / CurrentBallData.Cooldown;
			}
		}
	}

	UFUNCTION()
	void AddBowling(FGameplayTag BowlingID)
	{
		if (BowlingID.MatchesTag(GameplayTags::Bowling))
		{
			ItemPoolConfig.AddUniqueTag(BowlingID);
		}
	}

	/////////////////////////////////////////
	// Input
	/////////////////////////////////////////

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

	UFUNCTION()
	private void SetBowlingAimable(bool bValue)
	{
		bIsAimable = bValue;
	}

	UFUNCTION(BlueprintCallable)
	void TouchTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		bIsHoldTriggered = false;

		FHitResult outResult;
		TArray<EObjectTypeQuery> objectTypeArray;
		objectTypeArray.Add(EObjectTypeQuery::ReceiveInput);
		objectTypeArray.Add(EObjectTypeQuery::Pawn);
		if (PlayerController.GetHitResultUnderFingerForObjects(ETouchIndex::Touch1, objectTypeArray, false, outResult))
		{
			FVector location = GetActorLocation();
			EOnTouchTriggered.Broadcast(outResult.Actor, outResult.Location);
			if (bIsAimable)
			{
				if (outResult.Actor != this)
				{
					if (CooldownPercent > 0 && !AnimateInst.Montage_IsPlaying(AttackAnim))
					{
						// Gameplay::SetGlobalTimeDilation(0.15);

						if (!BowlingsMap.Find(ItemPoolConfig.GetRandomTag(), CurrentBallData))
						{
							PrintError("Bowling ID not found in data table");
						}
						AbilitySystem.SetBaseValue(n"AttackCooldown", CurrentBallData.Cooldown);
						AbilitySystem.SetBaseValue(n"Attack", CurrentBallData.Atk);
						// Print("Attack " + CurrentBallData.Atk);
						PredictLine.ClearInstances();
						CurrentTouchTarget = ETouchTarget::Battlefield;
						PressLoc = outResult.Location;
						location.Z = 0;
						BowlingPowerMultiplier = Math::Clamp(PressLoc.Distance(location) / BowlingPowerMark, 0.2, 1);
						// Print("Touch " + bowlingPowerMultiplier, 100);
						SetActorRotation(FRotator(0, FRotator::MakeFromX(location - PressLoc).ZYaw, 0));
						DrawPredictLine();

						AttackAnim.bEnableAutoBlendOut = false;
						AnimateInst.Montage_Play(AttackAnim);
						AnimateInst.Montage_JumpToSection(n"Start", AttackAnim);
					}
				}
				else
				{
					CurrentTouchTarget = ETouchTarget::Player;
					CalculateMovement(location, outResult.Location);
				}
			}
		}
	}

	UFUNCTION(BlueprintCallable)
	void HoldTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		FHitResult outResult;
		TArray<EObjectTypeQuery> objectTypeArray;
		objectTypeArray.Add(EObjectTypeQuery::ReceiveInput);
		objectTypeArray.Add(EObjectTypeQuery::Pawn);
		if (PlayerController.GetHitResultUnderFingerForObjects(ETouchIndex::Touch1, objectTypeArray, false, outResult))
		{
			FVector location = GetActorLocation();
			if (ElapsedTime >= HoldThreshold)
			{
				if (!bIsHoldTriggered)
				{
					bIsHoldTriggered = true;
					EOnHoldTriggered.Broadcast(outResult.Actor, outResult.Location);
				}
				EOnTouchHold.Broadcast(outResult.Actor, outResult.Location);
			}

			if (bIsAimable)
			{
				if (CurrentTouchTarget == ETouchTarget::Battlefield)
				{
					if (CooldownPercent > 0)
					{
						// The further distance between each hold, the faster the game speed.
						// Gameplay::SetGlobalTimeDilation(Math::Clamp(Math::Lerp(MinSlowTime, MaxSlowTime, PressLoc.DistSquared(outResult.Location) / MaxSlowTimeDistance), MinSlowTime, MaxSlowTime));

						PressLoc = outResult.Location;

						// location.Z = 0;
						float tempModifier = Math::Clamp(PressLoc.Distance(location) / BowlingPowerMark, 0.2, 1);
						float Yaw = FRotator::MakeFromX(location - PressLoc).ZYaw;

						if (!Math::IsNearlyEqual(Yaw, GetActorRotation().ZYaw) || !Math::IsNearlyEqual(BowlingPowerMultiplier, tempModifier))
						{
							BowlingPowerMultiplier = tempModifier;
							// Print("Hold " + bowlingPowerMultiplier, 100);
							SetActorRotation(FRotator(0, Yaw, 0));
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
	}

	UFUNCTION(BlueprintCallable)
	void ReleaseTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		if (bIsAimable)
		{
			if (CurrentTouchTarget == ETouchTarget::Battlefield)
			{
				if (CooldownPercent >= 1 && BowlingPowerMultiplier != 0)
				{
					SetCooldownPercent(0);

					ClearTween();
					FloatTween = UFCTweenBPActionFloat::TweenFloat(0, 1, AbilitySystem.GetValue(n"AttackCooldown"), EFCEase::InQuad);
					FloatTween.ApplyEasing.AddUFunction(this, n"SetCooldownPercent");
					FloatTween.Start();

					AttackAnim.bEnableAutoBlendOut = true;
					AnimateInst.Montage_Play(AttackAnim);
					AnimateInst.Montage_JumpToSection(n"Attacking", AttackAnim);
				}
				PredictLine.ClearInstances();
				PressLoc = FVector::ZeroVector;
				BowlingPowerMultiplier = 0;
			}
			else if (CurrentTouchTarget == ETouchTarget::Player)
			{
			}
			Gameplay::SetGlobalTimeDilation(1);
			CurrentTouchTarget = ETouchTarget::None;
		}
		FHitResult outResult;
		TArray<EObjectTypeQuery> objectTypeArray;
		objectTypeArray.Add(EObjectTypeQuery::ReceiveInput);
		objectTypeArray.Add(EObjectTypeQuery::Pawn);
		EOnTouchReleased.Broadcast(outResult.Actor, outResult.Location);
		if (bIsHoldTriggered)
		{
			EOnHoldReleased.Broadcast(outResult.Actor, outResult.Location);
		}
	}

	UFUNCTION()
	FVector GetAttackLocation()
	{
		return GetActorLocation();
	}

	UFUNCTION()
	FRotator GetAttackRotation()
	{
		return GetActorRotation();
	}

	UFUNCTION()
	private void OnAnimHitNotify()
	{
		if (AttackResponseComponent.DGetAttackLocation.IsBound() && AttackResponseComponent.DGetAttackRotation.IsBound())
		{
			ABowling SpawnedActor = Cast<ABowling>(SpawnActor(BowlingTemplate, AttackResponseComponent.DGetAttackLocation.Execute(), AttackResponseComponent.DGetAttackRotation.Execute()));
			CurrentBallData.Atk = AbilitySystem.GetValue(n"Attack");
			SpawnedActor.SetData(CurrentBallData);
			SpawnedActor.SetOwner(this);
			SpawnedActor.MovementResponseComponent.InitForce(-GetActorForwardVector(), CurrentBallData.BowlingSpeed);

			SpawnedActor.EOnHit.AddUFunction(this, n"OnHit");
			EOnBowlingSpawned.Broadcast(SpawnedActor);

			FMODBlueprint::PlayEvent2D(this, ThrowSFX, true);
		}
	}

	void ClearTween(bool bSkipCheck = false)
	{
		if (bSkipCheck || (IsValid(FloatTween) && FloatTween.IsValid()))
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
			FloatTween.SetTimeMultiplier(1);
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
		float newTimeDilation = Math::Clamp(Math::Lerp(MinSlowTime, MaxSlowTime, moveAmount / MaxSlowTimeDistance), MinSlowTime, MaxSlowTime);
		float newPosY = currentLocation.Y + Math::Sign(moveAmount) * Math::Clamp(Math::Abs(moveAmount), 0, AbilitySystem.GetValue(n"MoveSpeed") * Gameplay::GetWorldDeltaSeconds() / newTimeDilation);
		Gameplay::SetGlobalTimeDilation(newTimeDilation);
		SetActorLocation(FVector(currentLocation.X, Math::Clamp(newPosY, -MaxSlowTimeDistance, MaxSlowTimeDistance), currentLocation.Z));
	}

	UFUNCTION()
	void SetGuideArrowTarget(FVector Target)
	{
		WorldWidget.SetHiddenInGame(false);
		float Yaw = FRotator::MakeFromX(GetActorLocation() - Target).ZYaw;
		WorldWidget.SetWorldRotation(FRotator(90, 0, -Yaw));
	}

	UFUNCTION()
	void HideGuideArrow()
	{
		WorldWidget.SetHiddenInGame(true);
	}

	UFUNCTION(BlueprintCallable)
	void DrawPredictLine()
	{
		PredictLine.ClearInstances();
		FPredictProjectilePathParams PredictProjectilePathParams;
		PredictProjectilePathParams.StartLocation = GetActorLocation();
		PredictProjectilePathParams.bTraceWithCollision = true;
		PredictProjectilePathParams.TraceChannel = ECollisionChannel::Bowling;
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

		if (PredictProjectilePathResult.HitResult.GetActor() != nullptr)
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
		EOnCooldownUpdate.Broadcast(CooldownPercent);
		// Todo: Change this to event, then move the color update code to the event
	}

	UFUNCTION()
	void SetPredictLineColor(float iCooldownPercent)
	{
		if (iCooldownPercent >= 1)
		{
			PredictLineMaterial.SetVectorParameterValue(n"Base Color", THROWABLE_COLOR);
		}
		else if (iCooldownPercent > 0)
		{
			PredictLineMaterial.SetVectorParameterValue(n"Base Color", UNTHROWABLE_COLOR);
		}
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
			// TODO: Make this a data
			DBoostAttentionPercentage.ExecuteIfBound(0.1);
		}
	}

	UFUNCTION()
	void CoinComboHandler(int value)
	{
		OnComboTrigger(1);
	}

	//////////////////////////////
	// Visual Cue
	//////////////////////////////

	UFUNCTION()
	void WinGameAnimation()
	{
		PlayerController.ClearMappingContext();
		SetActorRotation(FRotator(0, -180, 0));
		SetActorLocation(FVector(750, 0, 40));
		auto FocusTracker = Gameplay::GetActorOfClass(AFocusTracker);
		FocusTracker.SetActorLocation(GetActorLocation() + FVector(0, 0, 30));
		FocusTracker.EOnSequenceFinished.AddUFunction(this, n"OnSequenceFinished");
	}

	UFUNCTION()
	private void OnSequenceFinished()
	{
		auto FocusTracker = Gameplay::GetActorOfClass(AFocusTracker);
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(FocusTracker.GetActorLocation().Z,
													   FocusTracker.GetActorLocation().Z + 10,
													   3.5f,
													   EFCEase::InOutSine);
		FloatTween.ApplyEasing.AddUFunction(FocusTracker, n"SetZLocation");
		FloatTween.Start();
		Gameplay::GetActorOfClass(ARewardChest).SetTarget(FocusTracker.ExtraTarget);
	}

	int GetComboCounter()
	{
		return ComboCounter;
	}
}
