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

	UPROPERTY(meta = (MultiLine = true))
	FText LevelDescription;

	UPROPERTY()
	ELevelType LevelType = ELevelType::Standard;

	UPROPERTY()
	float Delay;

	UPROPERTY()
	float SpawnSize;

	UPROPERTY()
	UDataTable SpawnSequenceDT;

	UPROPERTY(EditDefaultsOnly, Category = DefaultItems, meta = (Categories = "Bowling"))
	FItemPoolConfigDT BowlingsPoolConfig;

	UPROPERTY(EditDefaultsOnly, Category = DefaultItems, meta = (Categories = "Survivor"))
	FItemPoolConfigDT SurvivorsPoolConfig;

	UPROPERTY(EditDefaultsOnly, Category = DefaultItems, meta = (Categories = "Weapon"))
	FItemPoolConfigDT WeaponsPoolConfig;

	UPROPERTY(EditDefaultsOnly, Category = DefaultItems, meta = (Categories = "Ability"))
	FItemPoolConfigDT AbilitiesPoolConfig;

	UPROPERTY(EditDefaultsOnly, Category = DefaultItems, meta = (Categories = "Power"))
	FItemPoolConfigDT PowerPoolConfig;

	// Possible rewards: Power, Survivor, Weapon, Ability
	UPROPERTY(EditDefaultsOnly, Category = DefaultItems, meta = (Categories = "Survivor,Weapon,Ability,Power"))
	FGameplayTagContainer RewardConfigsDT;

	FGameplayTag GetRandomReward()
	{
		int Idx = RewardConfigsDT.Num() > 1 ? Math::RandRange(0, RewardConfigsDT.Num() - 1) : 0;
		return RewardConfigsDT.GameplayTags[Idx];
	}
}