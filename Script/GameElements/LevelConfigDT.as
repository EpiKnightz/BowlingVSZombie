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
	FItemPoolConfigDT BowlingPoolConfig;

	UPROPERTY()
	FItemPoolConfigDT SurvivorPoolConfig;

	UPROPERTY()
	FItemPoolConfigDT WeaponPoolConfig;

	UPROPERTY()
	FItemPoolConfigDT AbilitiesPoolConfig;

	// Possible rewards: Power, Survivor, Weapon, Ability
	UPROPERTY()
	FGameplayTagContainer RewardConfigsDT;

	FGameplayTag GetRandomReward()
	{
		int Idx = RewardConfigsDT.Num() > 1 ? Math::RandRange(0, RewardConfigsDT.Num() - 1) : 0;
		return RewardConfigsDT.GameplayTags[Idx];
	}
}