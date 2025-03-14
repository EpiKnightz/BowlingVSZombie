

class ASurvivorManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable SurvivorDataTable;

	TMap<FGameplayTag, FSurvivorDT> SurvivorsDataMap;
	TSet<FName> SpawnedSurvivorList;

	UPROPERTY()
	TSubclassOf<ASurvivor> SurvivorTemplate;

	FItemPoolConfigDT ItemPoolConfig;

	FSurvivorEvent EOnSurvivorSpawned;
	FBoolEvent EOnGameStateChanged;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FSurvivorDT> SurvivorsArray;
		SurvivorDataTable.GetAllRows(SurvivorsArray);
		for (FSurvivorDT Survivor : SurvivorsArray)
		{
			SurvivorsDataMap.Add(Survivor.SurvivorID, Survivor);
		}
	}

	UFUNCTION()
	void OnEndGame()
	{
		EOnGameStateChanged.Broadcast(false);
	}

	UFUNCTION()
	void AddCard(FCardDT CardData)
	{
		if (CardData.CardType == ECardType::Survivor)
		{
			ItemPoolConfig.AddUniqueTag(CardData.ItemID);
		}
	}

	UFUNCTION()
	FCardDT GetCardData(FGameplayTag CardID)
	{
		return FCardDT(GetSurvivorData(CardID));
	}

	UFUNCTION()
	FSurvivorDT GetSurvivorData(FGameplayTag SurvivorID)
	{
		FSurvivorDT Survivor;
		if (SurvivorsDataMap.Find(SurvivorID, Survivor) != false)
		{
			return Survivor;
		}
		else
		{
			PrintError("GetSurvivorData: SurvivorID not found");
			return Survivor;
		}
	}

	UFUNCTION()
	FSurvivorDT GetRankedSurvivorData(FGameplayTag SurvivorID, int Rank)
	{
		FGameplayTag RankedSurvivorID = FGameplayTag::RequestGameplayTag(FName(SurvivorID.ToString() + ".Lv" + Rank));
		return GetSurvivorData(RankedSurvivorID);
	}

	UFUNCTION()
	FSurvivorDT CreateSurvivorFromTag(FGameplayTag SurvivorID, ASurvivor& SpawnedActor)
	{
		FSurvivorDT SurvivorData;
		if (SurvivorsDataMap.Find(SurvivorID, SurvivorData) != false)
		{
			SpawnSurvivor(SpawnedActor, SurvivorData);
		}
		else
		{
			PrintError("CreateSurvivor: SurvivorID not found");
		}
		return SurvivorData;
	}

	UFUNCTION()
	bool CreateRandomSurvior(ASurvivor& SpawnedActor)
	{
		if (!ItemPoolConfig.IsEmpty())
		{
			FSurvivorDT SurvivorData;

			// SurvivorDataTable.FindRow(LevelItemsConfig.ItemIDs[NewSpawnedID], SurvivorData);
			SurvivorsDataMap.Find(ItemPoolConfig.ItemTags[Math::RandRange(0, ItemPoolConfig.Num() - 1)], SurvivorData);

			if (SurvivorData.SurvivorID.IsValid())
			{
				SpawnSurvivor(SpawnedActor, SurvivorData);
				return true;
			}
			else
			{
				PrintError("CreateRandomSurvior: SurvivorID not found");
				return false;
			}
		}
		else
		{
			PrintError("CreateRandomSurvior: ItemPoolConfig is empty");
			return false;
		}
	}

	void SpawnSurvivor(ASurvivor& SpawnedActor, FSurvivorDT& SurvivorData)
	{
		SpawnedActor = SpawnActor(SurvivorTemplate);
		SpawnedActor.SetData(SurvivorData, true);
		SpawnedActor.DGetRankedSurvivorData.BindUFunction(this, n"GetRankedSurvivorData");
		SpawnedSurvivorList.Add(SpawnedActor.GetName());
		EOnGameStateChanged.AddUFunction(SpawnedActor, n"EnableSurvivor");
		EOnSurvivorSpawned.Broadcast(SpawnedActor);
	}
};