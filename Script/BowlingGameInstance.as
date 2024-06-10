class UBowlingGameInstance : UGameInstance
{
	int CurrentLevel = 1;

	UFUNCTION(BlueprintOverride)
	void Init()
	{
#if EDITOR
		CurrentLevel = 3;
#endif
	}
};