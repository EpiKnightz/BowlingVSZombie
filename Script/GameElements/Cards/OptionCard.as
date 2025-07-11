enum EDragState
{
	None,
	Dragging,
	Overlapping
}

class AOptionCard : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent CardMesh;
	default CardMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent, Attach = CardMesh)
	UWidgetComponent TextWidget;
	default TextWidget.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default TextWidget.ReceivesDecals = false;
	UUICard CardWidget;

	UPROPERTY(DefaultComponent, Attach = CardMesh)
	UStaticMeshComponent CardBG;

	UPROPERTY()
	TArray<UTemplateSequence> IntroSequences;

	FCardDT CardData;

	FIntCardDelegate DOnCardClicked;
	FActorDelegate DOnTargetChosen;
	FVoidEvent EOnDragReleased;

	private ATemplateSequenceActor TemplSequActor;
	private int DisplayOrder; //  Can only be 0, 1, 2
	private int InventoryID;

	UPROPERTY()
	FTransform SurvivorTransform;
	UPROPERTY()
	FTransform WeaponTransform;
	UPROPERTY()
	FTransform AbilityTransform;

	FCardDTEvent EOnCardInit;

	// UPROPERTY()
	// TSubclassOf<ASurvivor> CompanionClass;

	protected UColorOverlay ColorOverlay;
	protected UMaterialInstanceDynamic CardBGMat;
	protected AActor Target;
	private ASurvivor SpawnedSurvivor;
	private AActor SpawnedWeaponActor;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.EOnHoldTriggered.AddUFunction(this, n"OnHoldTriggered");

		TemplSequActor = NewObject(this, ATemplateSequenceActor);

		CardWidget = Cast<UUICard>(TextWidget.GetWidget());
		if (IsValid(CardWidget))
		{
			EOnCardInit.AddUFunction(CardWidget, n"SetCardData");
		}

		ColorOverlay = NewObject(this, UColorOverlay);
		ColorOverlay.SetupDynamicMaterial(CardMesh.GetMaterial(0));
		CardMesh.SetMaterial(0, ColorOverlay.DynamicMat);
		CardBGMat = CardBG.CreateDynamicMaterialInstance(0);
		CardBG.SetMaterial(0, CardBGMat);
	}

	// ID can be 0, 1 or 2 for Left, Middle and Right cards
	UFUNCTION()
	void Init(int iDisplayOrder, AOptionCardManager OptionCardManager, FCardDT& iCardData)
	{
		DisplayOrder = iDisplayOrder;
		CardWidget.DGetAbilityDataFromTag = OptionCardManager.DGetAbilityDataFromTag;
		SetTimeScale(Gameplay::GetGlobalTimeDilation());

		switch (iCardData.CardType)
		{
			case ECardType::Survivor:
			{
				FSurvivorDT SurvivorData = OptionCardManager.DCreateSurvivorFromTag.ExecuteIfBound(iCardData.ItemID, SpawnedSurvivor);
				if (SurvivorData.IsValid())
				{
					CardData = SurvivorData;
					SpawnedSurvivor.SetActorLocationAndRotation(SurvivorTransform.Location, SurvivorTransform.Rotation.Rotator());
					// TODO move this into a component to avoid casting
					SpawnedSurvivor.AttachToActor(this, NAME_None, EAttachmentRule::KeepRelative);
					SpawnedSurvivor.SetTempScale(SurvivorTransform.Scale3D);
					SpawnedSurvivor.EOnDragReleased.AddUFunction(OptionCardManager, n"OnAnyDragReleased");
					CardWidget.SetSurvivorData(SurvivorData);
					CardWidget.SetWeaponData(OptionCardManager.DGetWeaponDataFromTag.ExecuteIfBound(SurvivorData.WeaponTag), SurvivorData.AttackCooldown);
				}
				break;
			}
			case ECardType::Weapon:
			{
				SpawnedWeaponActor = SpawnActor(AActor);
				UWeapon WeaponPtr;
				FWeaponDT WeaponData = OptionCardManager.DCreateWeaponFromTag.ExecuteIfBound(iCardData.ItemID, SpawnedWeaponActor, WeaponPtr);
				if (WeaponData.IsValid())
				{
					CardData = WeaponData;
					CardWidget.SetWeaponData(WeaponData);
					SpawnedWeaponActor.ActorEnableCollision = true;
					FRotator NewRotation = WeaponTransform.Rotation.Rotator();
					if (CardData.ItemID.MatchesTag(GameplayTags::Weapon_Range))
					{
						// Range weapon handle are different, so need to rotate it
						NewRotation -= FRotator(0, 90, 0);
						SpawnedWeaponActor.SetActorScale3D(WeaponTransform.Scale3D * 1.35);
					}
					else if (CardData.ItemID.MatchesTag(GameplayTags::Weapon_Melee))
					{
						SpawnedWeaponActor.SetActorScale3D(WeaponTransform.Scale3D);
					}
					SpawnedWeaponActor.SetActorLocationAndRotation(WeaponTransform.Location, NewRotation);
					SpawnedWeaponActor.AttachToActor(this, NAME_None, EAttachmentRule::KeepRelative);
					WeaponPtr.DOnTargetChosen.BindUFunction(OptionCardManager, n"OnTargetChosen");
					WeaponPtr.EOnDragReleased.AddUFunction(OptionCardManager, n"OnAnyDragReleased");

					if (WeaponData.EffectTags.HasTagExact(GameplayTags::Description_Weapon_DualWield))
					{
						auto WeaponMesh = UStaticMeshComponent::Create(this);
						WeaponMesh.SetStaticMesh(WeaponPtr.StaticMesh);
						NewRotation += FRotator(180, 270, 0);
						if (CardData.ItemID.MatchesTag(GameplayTags::Weapon_Range))
						{
							WeaponMesh.SetWorldScale3D(WeaponTransform.Scale3D * 1.35);
						}
						WeaponMesh.SetRelativeLocationAndRotation(FVector(WeaponTransform.Location.X, -WeaponTransform.Location.Y, 3.5),
																  NewRotation);
					}
				}
				break;
			}
			case ECardType::Ability:
			{
				CardData = OptionCardManager.DGetAbilityDataFromTag.ExecuteIfBound(iCardData.ItemID);
				DOnTargetChosen.BindUFunction(OptionCardManager, n"OnTargetChosen");
				EOnDragReleased.AddUFunction(OptionCardManager, n"OnAnyDragReleased");
				break;
			}
			default:
			{
				PrintError("Unknown card type");
				break;
			}
		}
		iCardData = CardData;

		UTemplateSequencePlayer::CreateTemplateSequencePlayer(IntroSequences[DisplayOrder], FMovieSceneSequencePlaybackSettings(), TemplSequActor);
		TemplSequActor.SetBinding(this);
		TemplSequActor.GetSequencePlayer().SetPlayRate(1 / Gameplay::GetGlobalTimeDilation());
		TemplSequActor.GetSequencePlayer().Play();
		TemplSequActor.GetSequencePlayer().OnFinished.AddUFunction(CardWidget, n"PlayIntroAnim");
		EOnCardInit.Broadcast(CardData);
	}

	void SetCardColor(FLinearColor RarityColor, TArray<FLinearColor> ElementColor)
	{
		CardWidget.SetRarityColor(RarityColor);
		ColorOverlay.ChangeOverlayColor(ElementColor[0]);
		if (ElementColor.Num() >= 2)
		{
			FLinearColor SubColor = ElementColor[1];
			SubColor.A = 1; // Enable dual color
			ColorOverlay.ChangeSubColor(SubColor);
		}
		else
		{
			ColorOverlay.ChangeSubColor(FLinearColor::Transparent);
		}
	}

	UFUNCTION()
	void OnHoldTriggered(AActor OtherActor, FVector Location)
	{
		if (OtherActor == this)
		{
			DOnCardClicked.ExecuteIfBound(DisplayOrder, CardData);
			switch (CardData.CardType)
			{
				case ECardType::Survivor:
				{
					SpawnedSurvivor.DetachFromActor();
					SpawnedSurvivor.ResetTransform();
					SpawnedSurvivor.RegisterDragEvents();
					SpawnedSurvivor = nullptr;
					OnFinished();
					break;
				}
				case ECardType::Weapon:
				{
					UWeapon WeaponPtr = UWeapon::Get(SpawnedWeaponActor);
					if (IsValid(WeaponPtr))
					{
						SpawnedWeaponActor.DetachFromActor();
						WeaponPtr.ResetTransform();
						WeaponPtr.RegisterDragEvents();
						SpawnedWeaponActor = nullptr;
						OnFinished();
					}
					break;
				}
				case ECardType::Ability:
				{
					SetActorLocationAndRotation(AbilityTransform.Location, AbilityTransform.Rotation.Rotator());
					SetActorRelativeScale3D(AbilityTransform.Scale3D);
					TextWidget.SetWidgetSpace(EWidgetSpace::World);
					RegisterDragEvents();
					Widget::SetInputMode_GameOnly(Gameplay::GetPlayerController(0));
					break;
				}
				default:
				{
					PrintError("Unknown card type");
					break;
				}
			}
		}
	}

	void RegisterDragEvents(bool bEnabled = true)
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.DSetBowlingAimable.ExecuteIfBound(!bEnabled);
		if (bEnabled)
		{
			Target = nullptr;
			ColorOverlay.ChangeOverlayColor(FLinearColor(1, 0, 0, -1));
			Collider.SetCollisionProfileName(n"Weapon");
			OnActorBeginOverlap.AddUFunction(this, n"OnOverlap");
			OnActorEndOverlap.AddUFunction(this, n"OnEndOverlap");
			Pawn.EOnTouchHold.AddUFunction(this, n"OnDragged");
		}
		else
		{
			Pawn.EOnTouchHold.UnbindObject(this);
			Pawn.EOnHoldReleased.UnbindObject(this);
			OnActorBeginOverlap.UnbindObject(this);
			OnActorEndOverlap.UnbindObject(this);
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			OnActorBeginOverlap.Clear();
			OnActorEndOverlap.Clear();
		}
	}

	UFUNCTION()
	private void OnOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		Print("OnOverlap");
		Target = OtherActor;
		ColorOverlay.ChangeOverlayColor(FLinearColor(0, 1, 0, -1));
	}

	UFUNCTION()
	private void OnEndOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		Target = nullptr;
		ColorOverlay.ChangeOverlayColor(FLinearColor(1, 0, 0, -1));
	}

	UFUNCTION()
	private void OnDragged(AActor OtherActor, FVector Vector)
	{
		SetActorLocation(FVector(Vector.X, Vector.Y, AbilityTransform.Location.Z));
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.EOnHoldReleased.AddUFunction(this, n"OnDragReleased");
	}

	UFUNCTION()
	private void OnDragReleased(AActor OtherActor, FVector Vector)
	{
		if (IsValid(Target))
		{
			Gameplay::SetGlobalTimeDilation(1);
			RegisterDragEvents(false);
			DOnTargetChosen.ExecuteIfBound(Target);
			EOnDragReleased.Broadcast();
			OnFinished();
		}
	}

	UFUNCTION()
	void Outro()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		TemplSequActor.GetSequencePlayer().PlayReverse();
		TemplSequActor.GetSequencePlayer().OnFinished.AddUFunction(this, n"OnFinished");
		TextWidget.SetVisibility(false);
	}

	UFUNCTION()
	private void OnFinished()
	{
		if (IsValid(SpawnedSurvivor))
		{
			SpawnedSurvivor.DestroyActor();
		}
		if (IsValid(SpawnedWeaponActor))
		{
			SpawnedWeaponActor.DestroyActor();
		}
		TextWidget.SetVisibility(false);
		Widget::SetInputMode_GameOnly(Gameplay::GetPlayerController(0));
		DestroyActor();
	}

	void SetTimeScale(float32 NewTimeScale)
	{
		ColorOverlay.DynamicMat.SetScalarParameterValue(n"TimeScale", NewTimeScale);
		CardBGMat.SetScalarParameterValue(n"TimeScale", NewTimeScale);
	}

	// UFUNCTION()
	// void ApplyTiltEffect(float DeltaSeconds)
	// {
	// 	FRotator NewRotation = CardMesh.GetRelativeRotation();
	// 	NewRotation = Math::RInterpTo(NewRotation, CalculateTiltEffect(), DeltaSeconds, 10);
	// 	CardMesh.SetRelativeRotation(NewRotation);
	// }

	// FRotator CalculateTiltEffect()
	// {
	// 	APlayerController PlayerController = Gameplay::GetPlayerController(0);
	// 	FHitResult HitResult;
	// 	if (PlayerController.GetHitResultUnderCursorByChannel(ETraceTypeQuery::Visibility, false, HitResult))
	// 	{
	// 		FVector ImpactPoint;
	// 		ImpactPoint = HitResult.ImpactPoint;
	// 		float InitialPitch = FRotator::MakeFromX(ImpactPoint - CardMesh.GetWorldLocation()).YPitch;
	// 		float FinalPitch = InitialPitch / 8;
	// 		bool CurrentSide = CardMesh.GetWorldLocation().Y > ImpactPoint.Y;
	// 		bool bCalculateYaw = true;
	// 		float FinalYaw, FinalRoll;
	// 		float MaxYaw, MinYaw;
	// 		if (bCalculateYaw)
	// 		{
	// 			if (InitialPitch > 0)
	// 			{
	// 				if (CurrentSide)
	// 				{
	// 					FinalYaw = MaxYaw;
	// 				}
	// 				else
	// 				{
	// 					FinalYaw = MinYaw;
	// 				}
	// 			}
	// 			else
	// 			{
	// 				if (CurrentSide)
	// 				{
	// 					FinalYaw = MinYaw;
	// 				}
	// 				else
	// 				{
	// 					FinalYaw = MaxYaw;
	// 				}
	// 			}
	// 		}
	// 		// FVector::ZeroVector.dist

	// 		if (CurrentSide)
	// 		{
	// 		}
	// 		return FRotator::ZeroRotator;
	// 	}
	// 	else
	// 	{
	// 		return FRotator::ZeroRotator;
	// 	}
	// }
};