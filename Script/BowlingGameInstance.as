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
#if EDITOR
		RunData.CurrentLevel = 1;
		RunData.MaxRunHP = 100;
		RunData.CurrentRunHP = 100;
		// RunCoinTotal = 200;
#endif
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