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

	private ATemplateSequenceActor TemplSequActor;
	private int ID;

	UPROPERTY()
	FTransform SurvivorTransform;
	UPROPERTY()
	FTransform WeaponTransform;

	FCardDTEvent EOnCardInit;

	// UPROPERTY()
	// TSubclassOf<ASurvivor> CompanionClass;

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
					}
					break;
				}
				case ECardType::Ability:
				{
					break;
				}
				default:
				{
					PrintError("Unknown card type");
					break;
				}
			}
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