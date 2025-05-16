struct FRunData
{
	int CurrentLevel = 1;
	TArray<FCardDT> CurrentCardInventory;
	int RunCoinTotal;
	float CurrentRunHP;
	float MaxRunHP = 100;
	FGameplayTagContainer RunTags;
}

class UBowlingGameInstance : UGameInstance
{

	// Run data:
	FRunData RunData;
	FIntEvent EOnCoinChange;

	UFUNCTION(BlueprintOverride)
	void Init()
	{
		LoadSaveRun();
		// #if EDITOR
		// 		RunData.CurrentLevel = 1;
		// 		RunData.MaxRunHP = 100;
		// 		RunData.CurrentRunHP = 100;
		// 		RunData.RunCoinTotal = 200;
		// 		RunData.RunTags.AddTag(GameplayTags::Map_Tutorial);
		// #endif
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
		RunData.CurrentLevel = 1;
		RunData.MaxRunHP = 100;
		RunData.CurrentRunHP = 100;
		RunData.RunCoinTotal = 200;
		RunData.RunTags.AddTag(GameplayTags::Map_Tutorial);
		SaveRun();
	}

	void SaveRun()
	{
		USaveRun SaveRun = Gameplay::CreateSaveGameObject(USaveRun);
		SaveRun.RunData = RunData;
		Gameplay::AsyncSaveGameToSlot(SaveRun, "SaveRun", 0); // Might need to handle saving delegate/error here
	}

	UFUNCTION()
	void AddCardToInventory(FCardDT Reward)
	{
		RunData.CurrentCardInventory.AddUnique(Reward);
	}

	UFUNCTION()
	void OnShopItemBought(FCardDT Item)
	{
		RunData.CurrentCardInventory.AddUnique(Item);
		ChangeInvCoinAmount(-Item.Cost);
	}

	UFUNCTION()
	void ChangeInvCoinAmount(int CoinChanges)
	{
		RunData.RunCoinTotal += CoinChanges;
		EOnCoinChange.Broadcast(RunData.RunCoinTotal);
	}

	UFUNCTION()
	void SetRunHP(float HPAmount)
	{
		RunData.CurrentRunHP = Math::Clamp(HPAmount, 0, RunData.MaxRunHP);
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
	TArray<FCardDT> GetCurrentCardInventory()
	{
		return RunData.CurrentCardInventory;
	}

	UFUNCTION()
	bool HasTag(FGameplayTag Tag)
	{
		return RunData.RunTags.HasTag(Tag);
	}
};