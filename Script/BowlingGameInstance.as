class UBowlingGameInstance : UGameInstance
{
	int CurrentLevel = 1;

	UFUNCTION(BlueprintOverride)
	void Init()
	{
		CurrentLevel = 2;
	}
};