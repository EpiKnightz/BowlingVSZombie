struct FLevelConfigsDT
{
	UPROPERTY()
	int Level;

	UPROPERTY()
	float Delay;

	UPROPERTY()
	float SpawnSize;

	UPROPERTY()
	UDataTable SpawnSequenceDT;

	UPROPERTY()
	FItemConfigsDT ItemConfigsDT;

	UPROPERTY()
	FItemConfigsDT SurvivorConfigsDT;

	UPROPERTY()
	FItemConfigsDT RewardConfigsDT;
}