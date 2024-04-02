enum ESpawnType
{
	Zombie,
	PowerUp
}

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

	UPROPERTY(meta = (EditCondition = "bAllowMultipleSpawns", EditConditionHides))
	int MinSpawnPerMulti;

	UPROPERTY(meta = (EditCondition = "bAllowMultipleSpawns", EditConditionHides))
	int MaxSpawnPerMulti;

	UPROPERTY(meta = (EditCondition = "bAllowMultipleSpawns", EditConditionHides))
	float MultipleSpawnInterval;

	UPROPERTY()
	FText WaveWarning;

	UPROPERTY()
	ESpawnType SpawnType;

	UPROPERTY()
	TArray<FName> SpawnID;

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
