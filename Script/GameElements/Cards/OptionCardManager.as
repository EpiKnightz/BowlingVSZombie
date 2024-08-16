const float TIME_SCALE_WHEN_SPAWNED_CARD = 0.05;
const int MAX_RANDOM_RETRY = 6;

class AOptionCardManager : AActor
{
	UPROPERTY()
	TSubclassOf<AOptionCard> CardTemplate;

	TArray<FCardDT> CurrentCardInventory;

	// This is to display the card in the game, from left to right: 0, 1, 2
	int CurrentID = 0;
	FCardDT SelectedCardData;
	TMap<int, AOptionCard> CardSelectionMap;
	int CurrentSelectionID = 0;
	TMap<int, FCardDT> CardInventory;

	private int LastSpawnedID = -1;
	private int SpawnWaveCount = 0;

	FTagSurvivor2DataDelegate DCreateSurvivorFromTag;
	FTagWeapon2DataDelegate DCreateWeaponFromTag;
	FTagAbility2DataDelegate DGetAbilityDataFromTag;
	FCardDTEvent EOnCardAdded;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.EOnTouchReleased.AddUFunction(this, n"OnDragReleased");
	}

	void GameStart()
	{
		System::SetTimer(this, n"SpawnCard", 0.5, false);
	}

	void GamePause()
	{}

	void EndGame()
	{
		System::ClearTimer(this, "SpawnCard");
	}

	void AddCard(FCardDT Card)
	{
		CardInventory.Add(CurrentSelectionID, Card);
		CurrentSelectionID++;
		EOnCardAdded.Broadcast(Card);
	}

	FCardDT GetRandomCard(ECardType ForceCardType = ECardType::None)
	{
		int NewSpawnedID = Math::RandRange(0, CardInventory.Num() - 1);
		// Retry until we get a different ID, or exceeded MAX_RANDOM_RETRY
		int CurrentRetry = 0;

		while ((NewSpawnedID == LastSpawnedID
				|| (ForceCardType != ECardType::None && CardInventory[NewSpawnedID].CardType != ForceCardType))
			   && CurrentRetry < MAX_RANDOM_RETRY
			   && CardInventory.Num() > 1)
		{
			NewSpawnedID = Math::RandRange(0, CardInventory.Num() - 1);
			CurrentRetry++;
		}
		LastSpawnedID = NewSpawnedID;
		return CardInventory.Num() > 0 ? CardInventory[NewSpawnedID] : FCardDT();
	}

	UFUNCTION()
	void SpawnCard()
	{
		Gameplay::SetGlobalTimeDilation(TIME_SCALE_WHEN_SPAWNED_CARD);
		AOptionCard Card = SpawnActor(CardTemplate);
		Card.DOnCardClicked.BindUFunction(this, n"OnCardClicked");
		ECardType ForceCardType = ECardType::None;
		if (SpawnWaveCount == 0)
		{
			ForceCardType = ECardType::Survivor;
		}
		Card.Init(CurrentID, this, GetRandomCard(ForceCardType));
		CardSelectionMap.Add(CurrentID, Card);
		CurrentID++;
		if (CurrentID < 3)
		{
			System::SetTimer(this, n"SpawnCard", 0.5 * TIME_SCALE_WHEN_SPAWNED_CARD, false);
		}
		else
		{
			SpawnWaveCount++;
			LastSpawnedID = -1;
		}
	}

	UFUNCTION()
	void OnCardClicked(int ID, FCardDT CardData)
	{
		SelectedCardData = CardData;
		for (int i = 0; i < CardSelectionMap.Num(); i++)
		{
			if (i != ID)
			{
				CardSelectionMap.FindOrAdd(i).Outro();
			}
		}
	}

	UFUNCTION()
	void OnTargetChosen(AActor Target)
	{
		ASurvivor Survivor = Cast<ASurvivor>(Target);
		if (IsValid(Survivor))
		{
			if (SelectedCardData.CardType == ECardType::Weapon)
			{
				Survivor.ChangeWeapon(SelectedCardData.ItemID);
			}
			else if (SelectedCardData.CardType == ECardType::Ability)
			{
				Survivor.AddAbility(SelectedCardData.ItemID);
			}
		}
	}

	UFUNCTION()
	private void OnDragReleased(AActor OtherActor, FVector Vector)
	{
		// DCreateWeaponFromTag
		CurrentID = 0;
		System::SetTimer(this, n"SpawnCard", 10, false);
	}
};