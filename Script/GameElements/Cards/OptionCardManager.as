class AOptionCardManager : AActor
{
	UPROPERTY()
	TSubclassOf<AOptionCard> CardTemplate;

	int CurrentID = 0;
	TMap<int, AOptionCard> CardMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		System::SetTimer(this, n"SpawnCard", 0.5, false);
	}

	UFUNCTION()
	void SpawnCard()
	{
		AOptionCard Card = SpawnActor(CardTemplate);
		Card.DOnCardClicked.BindUFunction(this, n"OnCardClicked");
		Card.Init(CurrentID);
		CardMap.Add(CurrentID, Card);
		CurrentID++;
		if (CurrentID < 3)
		{
			System::SetTimer(this, n"SpawnCard", 0.5, false);
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
	}
};