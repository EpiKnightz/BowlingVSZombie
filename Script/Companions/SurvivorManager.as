const int MAX_RANDOM_RETRY = 3;

class ASurvivorManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable SurvivorDataTable;

	TMap<FGameplayTag, FSurvivorDT> SurvivorsDataMap;

	UPROPERTY()
	TSubclassOf<ASurvivor> SurvivorTemplate;

	FItemConfigsDT ItemsConfig;

	private int LastSpawnedID = -1;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FSurvivorDT> SurvivorsArray;
		SurvivorDataTable.GetAllRows(SurvivorsArray);
		for (FSurvivorDT Ability : SurvivorsArray)
		{
			SurvivorsDataMap.Add(Ability.SurvivorID, Ability);
		}
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
	bool CreateSurvivor(FGameplayTag SurvivorID, ASurvivor& ActorToSpawned)
	{
		FSurvivorDT SurvivorData;
		if (SurvivorsDataMap.Find(SurvivorID, SurvivorData) != false)
		{
			ActorToSpawned = SpawnActor(SurvivorTemplate);
			ActorToSpawned.SetData(SurvivorData);
			return true;
		}
		else
		{
			return false;
		}
	}

	UFUNCTION()
	bool CreateRandomSurvior(ASurvivor& ActorToSpawned)
	{
		FSurvivorDT SurvivorData;
		int NewSpawnedID = Math::RandRange(0, ItemsConfig.ItemIDs.Num() - 1);
		int CurrentRetry = 0;
		while (NewSpawnedID == LastSpawnedID
			   && CurrentRetry < MAX_RANDOM_RETRY
			   && ItemsConfig.ItemIDs.Num() > 1)
		{
			NewSpawnedID = Math::RandRange(0, ItemsConfig.ItemIDs.Num() - 1);
			CurrentRetry++;
		}
		SurvivorDataTable.FindRow(ItemsConfig.ItemIDs[NewSpawnedID], SurvivorData);
		LastSpawnedID = NewSpawnedID;
		if (SurvivorData.SurvivorID.IsValid())
		{
			ActorToSpawned = SpawnActor(SurvivorTemplate);
			ActorToSpawned.SetData(SurvivorData);
			return true;
		}
		else
		{
			PrintError("CreateRandomSurvior: SurvivorID not found");
			return false;
		}
	}
};

// Spawn random survivor at start
// Fill "noise" bar to 100% -> can spawn again?
// Later
