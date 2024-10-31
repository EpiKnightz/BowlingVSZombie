class UBowlingGameInstance : UGameInstance
{
	int CurrentLevel = 1;

	// Run data:
	TArray<FCardDT> CurrentCardInventory;
	int RunCoinTotal;
	float CurrentRunHP;
	float MaxRunHP = 100;

	FIntEvent EOnCoinChange;

	UFUNCTION(BlueprintOverride)
	void Init()
	{
#if EDITOR
		CurrentLevel = 6;
		MaxRunHP = 100;
		CurrentRunHP = 100;
		// RunCoinTotal = 200;
#endif
	}

	UFUNCTION()
	void AddCardToInventory(FCardDT Reward)
	{
		CurrentCardInventory.AddUnique(Reward);
	}

	UFUNCTION()
	void OnShopItemBought(FCardDT Item)
	{
		CurrentCardInventory.AddUnique(Item);
		ChangeInvCoinAmount(-Item.Cost);
	}

	UFUNCTION()
	void ChangeInvCoinAmount(int CoinChanges)
	{
		RunCoinTotal += CoinChanges;
		EOnCoinChange.Broadcast(RunCoinTotal);
	}

	UFUNCTION()
	void SetRunHP(float HPAmount)
	{
		CurrentRunHP = Math::Clamp(HPAmount, 0, MaxRunHP);
	}

	UFUNCTION()
	void RestoreRunHPPercent(float Percent)
	{
		SetRunHP(CurrentRunHP + CurrentRunHP * Percent);
	}

	UFUNCTION()
	void RestoreRunHPAmount(float Amount)
	{
		SetRunHP(CurrentRunHP + Amount);
	}
};