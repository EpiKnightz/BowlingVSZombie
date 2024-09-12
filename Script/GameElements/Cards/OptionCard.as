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

	UPROPERTY()
	TArray<UTemplateSequence> IntroSequences;

	FCardDT CardData;

	FIntCardDelegate DOnCardClicked;
	FActorDelegate DOnTargetChosen;

	private ATemplateSequenceActor TemplSequActor;
	private int ID;

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
	protected AActor Target;
	private ASurvivor SpawnedSurvivor;
	private AActor SpawnedWeapon;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.EOnTouchTriggered.AddUFunction(this, n"OnTouchTriggered");

		TemplSequActor = NewObject(this, ATemplateSequenceActor);

		UUICard CardWidget = Cast<UUICard>(TextWidget.GetWidget());
		if (IsValid(CardWidget))
		{
			EOnCardInit.AddUFunction(CardWidget, n"SetCardData");
		}

		ColorOverlay = NewObject(this, UColorOverlay);
		ColorOverlay.SetupDynamicMaterial(CardMesh.GetMaterial(0));
		CardMesh.SetMaterial(0, ColorOverlay.DynamicMat);
	}

	// ID can be 0, 1 or 2
	UFUNCTION()
	void Init(int iID, AOptionCardManager OptionCardManager, FCardDT iCardData)
	{
		ID = iID;

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
				}
				break;
			}
			case ECardType::Weapon:
			{
				SpawnedWeapon = SpawnActor(AActor);
				UWeapon WeaponPtr;
				FWeaponDT WeaponData = OptionCardManager.DCreateWeaponFromTag.ExecuteIfBound(iCardData.ItemID, SpawnedWeapon, WeaponPtr);
				if (WeaponData.IsValid())
				{
					CardData = WeaponData;
					SpawnedWeapon.ActorEnableCollision = true;
					FRotator NewRotation = WeaponTransform.Rotation.Rotator();
					if (CardData.ItemID.MatchesTag(GameplayTags::Weapon_Range))
					{
						// Range weapon handle are different, so need to rotate it
						NewRotation -= FRotator(0, 90, 0);
						SpawnedWeapon.SetActorScale3D(WeaponTransform.Scale3D * 1.25);
					}
					else if (CardData.ItemID.MatchesTag(GameplayTags::Weapon_Melee))
					{
						SpawnedWeapon.SetActorScale3D(WeaponTransform.Scale3D);
					}
					SpawnedWeapon.SetActorLocationAndRotation(WeaponTransform.Location, NewRotation);
					SpawnedWeapon.AttachToActor(this, NAME_None, EAttachmentRule::KeepRelative);
					WeaponPtr.DOnTargetChosen.BindUFunction(OptionCardManager, n"OnTargetChosen");
				}
				break;
			}
			case ECardType::Ability:
			{
				CardData = OptionCardManager.DGetAbilityDataFromTag.ExecuteIfBound(iCardData.ItemID);
				DOnTargetChosen.BindUFunction(OptionCardManager, n"OnTargetChosen");
				break;
			}
			default:
			{
				PrintError("Unknown card type");
				break;
			}
		}

		UTemplateSequencePlayer::CreateTemplateSequencePlayer(IntroSequences[ID], FMovieSceneSequencePlaybackSettings(), TemplSequActor);
		TemplSequActor.SetBinding(this);
		TemplSequActor.GetSequencePlayer().SetPlayRate(1 / Gameplay::GetGlobalTimeDilation());
		TemplSequActor.GetSequencePlayer().Play();
		EOnCardInit.Broadcast(CardData);
	}

	UFUNCTION()
	void OnTouchTriggered(AActor OtherActor, FVector Location)
	{
		if (OtherActor == this)
		{
			DOnCardClicked.ExecuteIfBound(ID, CardData);
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
					UWeapon WeaponPtr = UWeapon::Get(SpawnedWeapon);
					if (IsValid(WeaponPtr))
					{
						SpawnedWeapon.DetachFromActor();
						WeaponPtr.ResetTransform();
						WeaponPtr.RegisterDragEvents();
						SpawnedWeapon = nullptr;
						OnFinished();
					}
					break;
				}
				case ECardType::Ability:
				{
					SetActorLocationAndRotation(AbilityTransform.Location, AbilityTransform.Rotation.Rotator());
					SetActorRelativeScale3D(AbilityTransform.Scale3D);
					RegisterDragEvents();
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
		if (bEnabled)
		{
			Target = nullptr;
			ColorOverlay.ChangeOverlayColor(FLinearColor(1, 0, 0, -1));
			Collider.SetCollisionProfileName(n"Weapon");
			OnActorBeginOverlap.AddUFunction(this, n"OnOverlap");
			OnActorEndOverlap.AddUFunction(this, n"OnEndOverlap");
			Pawn.EOnTouchHold.AddUFunction(this, n"OnDragged");
			Pawn.EOnTouchReleased.AddUFunction(this, n"OnDragReleased");
		}
		else
		{
			Pawn.EOnTouchHold.UnbindObject(this);
			Pawn.EOnTouchReleased.UnbindObject(this);
			OnActorBeginOverlap.UnbindObject(this);
			OnActorEndOverlap.UnbindObject(this);
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			OnActorBeginOverlap.Clear();
			OnActorEndOverlap.Clear();
		}
		Pawn.DSetBowlingAimable.ExecuteIfBound(!bEnabled);
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
	}

	UFUNCTION()
	private void OnDragReleased(AActor OtherActor, FVector Vector)
	{
		if (IsValid(Target))
		{
			Gameplay::SetGlobalTimeDilation(1);
			RegisterDragEvents(false);
			DOnTargetChosen.ExecuteIfBound(Target);
			OnFinished();
		}
	}

	UFUNCTION()
	void Outro()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		TemplSequActor.GetSequencePlayer().PlayReverse();
		TemplSequActor.GetSequencePlayer().OnFinished.AddUFunction(this, n"OnFinished");
	}

	UFUNCTION()
	private void OnFinished()
	{
		if (IsValid(SpawnedSurvivor))
		{
			SpawnedSurvivor.DestroyActor();
		}
		if (IsValid(SpawnedWeapon))
		{
			SpawnedWeapon.DestroyActor();
		}
		DestroyActor();
	}
};