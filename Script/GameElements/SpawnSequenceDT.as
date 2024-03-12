struct FSpawnSequenceDT
{
	UPROPERTY()
	float TimeMark;

	UPROPERTY()
	float MinWaveCooldown;

	UPROPERTY()
	float MaxWaveCooldown;

	UPROPERTY()
	bool bAllowMultipleSpawns;

	UPROPERTY()
	int MinSpawnPerMulti;

	UPROPERTY()
	int MaxSpawnPerMulti;

	UPROPERTY()
	float MultipleSpawnInterval;

	UPROPERTY()
	FText WaveWarning;

	UPROPERTY()
	TArray<FName> ZombieID;

	int opCmp(FSpawnSequenceDT Other) const
	{
		if (TimeMark < Other.TimeMark)
		{
			return -1;
		}
		else if (TimeMark > Other.TimeMark)
		{
			return 1;
		}
		return 0;
	}
}
