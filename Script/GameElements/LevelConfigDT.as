enum ELevelType
{
	Standard,
	Shop,
	Rest,
	Boss,
}

struct FLevelConfigsDT
{
	UPROPERTY()
	int Level;

	UPROPERTY()
	FText LevelDescription;

	UPROPERTY()
	ELevelType LevelType = ELevelType::Standard;

	UPROPERTY()
	float Delay;

	UPROPERTY()
	float SpawnSize;

	UPROPERTY()
	UDataTable SpawnSequenceDT;

	UPROPERTY()
	FItemPoolConfigDT BowlingsPoolConfig;

	UPROPERTY()
	FItemPoolConfigDT SurvivorsPoolConfig;

	UPROPERTY()
	FItemPoolConfigDT WeaponsPoolConfig;

	UPROPERTY()
	FItemPoolConfigDT AbilitiesPoolConfig;

	UPROPERTY()
	FItemPoolConfigDT PowerPoolConfig;

	// Possible rewards: Power, Survivor, Weapon, Ability
	UPROPERTY()
	FGameplayTagContainer RewardConfigsDT;

	FGameplayTag GetRandomReward()
	{
		int Idx = RewardConfigsDT.Num() > 1 ? Math::RandRange(0, RewardConfigsDT.Num() - 1) : 0;
		return RewardConfigsDT.GameplayTags[Idx];
	}
}