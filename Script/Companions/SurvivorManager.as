class ASurvivorManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable SurvivorDataTable;

	TMap<FGameplayTag, FSurvivorDT> SurvivorsDataMap;

	UPROPERTY()
	TSubclassOf<ASurvivor> SurvivorTemplate;

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
		SurvivorDataTable.FindRow(FName("Item_" + Math::RandRange(0, SurvivorsDataMap.Num() - 1)), SurvivorData);
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