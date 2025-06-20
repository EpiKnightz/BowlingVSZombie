struct FRunData
{
	TArray<FCardDT> CurrentCardInventory;
	int RunCoinTotal;
	float CurrentRunHP;
	float MaxRunHP = 100;
	FGameplayTagContainer RunTags;

	// Map data
	int InitialSeed = -1;
	int CurrentLevel = 0;
	TArray<int> ClearedLevels;
}

class UBowlingGameInstance : UGameInstance
{

	// Run data:
	FRunData RunData;
	FIntEvent EOnCoinChange;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIBoard> UIBoard;

	UFUNCTION(BlueprintOverride)
	void Init()
	{
		LoadSaveRun();
		// CreateSaveRun();
	}

	void ResetSave()
	{
		RunData.CurrentLevel = 0;
		RunData.MaxRunHP = 100;
		RunData.CurrentRunHP = 100;
		RunData.RunCoinTotal = 200;
		RunData.CurrentCardInventory.Empty();
		RunData.RunTags.AddTag(GameplayTags::Map_Tutorial);
		RunData.ClearedLevels.Empty();
		SaveRun();
	}

	void LoadSaveRun(bool bCreateNewIfFailed = true)
	{
		USaveRun SaveRun = Cast<USaveRun>(Gameplay::LoadGameFromSlot("SaveRun", 0));
		if (IsValid(SaveRun))
		{
			RunData = SaveRun.RunData;
		}
		else if (bCreateNewIfFailed)
		{
			CreateSaveRun();
		}
	}

	void CreateSaveRun()
	{
		ResetSave();
		SaveRun();
	}

	void SaveRun()
	{
		USaveRun SaveRun = Gameplay::CreateSaveGameObject(USaveRun);
		SaveRun.RunData = RunData;
		Gameplay::AsyncSaveGameToSlot(SaveRun, "SaveRun", 0); // Might need to handle saving delegate/error here
	}

	void SaveSeed(int Seed)
	{
		RunData.InitialSeed = Seed;
		SaveRun();
	}

	UFUNCTION()
	void AddCardToInventory(FCardDT Reward)
	{
		// Doing a pool-like system so allowing duplicates now
		RunData.CurrentCardInventory.Add(Reward);
		SaveRun();
	}

	UFUNCTION()
	void OnShopItemBought(FCardDT Item)
	{
		// Doing a pool-like system so allowing duplicates now
		RunData.CurrentCardInventory.Add(Item);
		ChangeInvCoinAmount(-Item.Cost);
		SaveRun();
	}

	UFUNCTION()
	void ChangeInvCoinAmount(int CoinChanges)
	{
		RunData.RunCoinTotal += CoinChanges;
		EOnCoinChange.Broadcast(RunData.RunCoinTotal);
		SaveRun();
	}

	UFUNCTION()
	void SetRunHP(float HPAmount)
	{
		RunData.CurrentRunHP = Math::Clamp(HPAmount, 0, RunData.MaxRunHP);
		SaveRun();
	}

	UFUNCTION()
	void RestoreRunHPPercent(float Percent)
	{
		SetRunHP(RunData.CurrentRunHP + RunData.CurrentRunHP * Percent);
	}

	UFUNCTION()
	void RestoreRunHPAmount(float Amount)
	{
		SetRunHP(RunData.CurrentRunHP + Amount);
	}

	UFUNCTION()
	int GetCurrentLevel()
	{
		return RunData.CurrentLevel;
	}

	UFUNCTION()
	void SetCurrentLevel(int Level)
	{
		RunData.CurrentLevel = Level;
		SaveRun();
	}

	UFUNCTION()
	int GetRunCoinTotal()
	{
		return RunData.RunCoinTotal;
	}

	UFUNCTION()
	float GetCurrentRunHP()
	{
		return RunData.CurrentRunHP;
	}

	UFUNCTION()
	float GetMaxRunHP()
	{
		return RunData.MaxRunHP;
	}

	UFUNCTION()
	void CompleteLevel()
	{
		RunData.ClearedLevels.Add(RunData.CurrentLevel);
		SaveRun();
	}

	UFUNCTION()
	TArray<FCardDT> GetCurrentCardInventory()
	{
		return RunData.CurrentCardInventory;
	}

	UFUNCTION()
	bool HasTag(FGameplayTag Tag)
	{
		return RunData.RunTags.HasTag(Tag);
	}

	UFUNCTION(BlueprintCallable)
	UUIBoard ShowBoardUI()
	{
		UUIBoard BoardWidget = Cast<UUIBoard>(WidgetBlueprint::CreateWidget(UIBoard, Gameplay::GetPlayerController(0)));
		BoardWidget.AddToViewport();
		return BoardWidget;
	}

	UFUNCTION(BlueprintCallable)
	void NextLevel(int NextLevel = -1)
	{
		if (NextLevel == -1)
		{
			SetCurrentLevel(GetCurrentLevel() + 1);
		}
		else
		{
			SetCurrentLevel(NextLevel);
		}
		SaveRun();
		StartActionMap();
	}

	UFUNCTION()
	void StartActionMap()
	{
		AGameMode GameMode = Cast<AGameMode>(Gameplay::GetGameMode());
		if (IsValid(GameMode) && GameMode.IsA(ABowlingGameMode))
		{
			GameMode.RestartGame();
		}
		else
		{
			Gameplay::OpenLevel(n"M_ActionPhaseFinal");
		}
	}
};