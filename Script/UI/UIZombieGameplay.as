
class UUIZombieGameplay : UUserWidget
{
	UPROPERTY(BlueprintReadWrite)
	ABowlingPawn BowlingPawn;

	UFUNCTION(BlueprintEvent)
	void UpdateScore(int NewScore)
	{
	}

	UFUNCTION(BlueprintEvent)
	void UpdateHP(int NewHP)
	{
	}

	UFUNCTION(BlueprintEvent)
	void WinUI()
	{
	}

	UFUNCTION(BlueprintEvent)
	void LoseUI()
	{
	}
}
