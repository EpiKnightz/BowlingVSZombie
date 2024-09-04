class UBowlingGameInstance : UGameInstance
{
	int CurrentLevel = 1;

	// Run data:
	TArray<FCardDT> CurrentCardInventory;
	int RunCoinTotal;

	UFUNCTION(BlueprintOverride)
	void Init()
	{
#if EDITOR
		CurrentLevel = 2;
#endif
	}

	UFUNCTION()
	void AddRewards(FCardDT Reward)
	{
		CurrentCardInventory.Add(Reward);
	}

	UFUNCTION()
	void AddCoin(int MatchCoin)
	{
		RunCoinTotal += MatchCoin;
	}
};