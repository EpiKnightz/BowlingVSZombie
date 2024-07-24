class UBowlingGameInstance : UGameInstance
{
	int CurrentLevel = 1;

	TArray<FCardDT> CurrentPowers;

	UFUNCTION(BlueprintOverride)
	void Init()
	{
#if EDITOR
		CurrentLevel = 3;
#endif
	}

	UFUNCTION()
	void AddRewards(FCardDT Reward)
	{
		CurrentPowers.Add(Reward);
	}
};