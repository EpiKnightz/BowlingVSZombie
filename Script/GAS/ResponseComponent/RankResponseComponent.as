class URankResponseComponent : UResponseComponent
{
	int CurrentRank = 1;

	FIntEvent EOnRankUp;

	UFUNCTION()
	void RankUp()
	{
		if (CurrentRank < 3)
		{
			CurrentRank++;
			EOnRankUp.Broadcast(CurrentRank);
		}
	}

	bool IsMaxRank()
	{
		return CurrentRank >= 3;
	}
};