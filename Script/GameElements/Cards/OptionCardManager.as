const float TIME_SCALE_WHEN_SPAWNED_CARD = 0.05;

class AOptionCardManager : AActor
{
	UPROPERTY()
	TSubclassOf<AOptionCard> CardTemplate;

	int CurrentID = 0;
	TMap<int, AOptionCard> CardMap;

	UPROPERTY()
	TArray<TSubclassOf<ASurvivor>> CompanionClasses;

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

	UFUNCTION()
	void SpawnCard()
	{
		Gameplay::SetGlobalTimeDilation(TIME_SCALE_WHEN_SPAWNED_CARD);
		AOptionCard Card = SpawnActor(CardTemplate);
		Card.DOnCardClicked.BindUFunction(this, n"OnCardClicked");
		Card.Init(CurrentID);
		CardMap.Add(CurrentID, Card);
		CurrentID++;
		if (CurrentID < 3)
		{
			System::SetTimer(this, n"SpawnCard", 0.5 * TIME_SCALE_WHEN_SPAWNED_CARD, false);
		}
	}

	UFUNCTION()
	void OnCardClicked(int ID)
	{
		for (int i = 0; i < CardMap.Num(); i++)
		{
			if (i != ID)
			{
				CardMap.FindOrAdd(i).Outro();
			}
		}

		CurrentID = 0;
		System::SetTimer(this, n"SpawnCard", 15, false);
	}
};