enum ESocketType
// ESocketType is an enumeration of socket types that can be equipped on a character
{
	None,
	Hand,
	Shield,
	Pistol,
	Gun,
	DualWield
}

enum EZombieType
{
	Normal,
	Elite,
	Boss
}

struct FZombieDT
{
	UPROPERTY()
	FGameplayTag ZombieID;

	UPROPERTY()
	FString Name = "Zombie";

	UPROPERTY()
	FText Description = FText::FromString("Zombie");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	EZombieType Type = EZombieType::Normal;

	UPROPERTY(Category = BaseStats)
	float32 HP = 100;

	// Atk is amount of power dealing to obstacles
	UPROPERTY(Category = BaseStats)
	float32 Atk = 10;

	UPROPERTY(Category = BaseStats)
	float32 Speed = 100;

	UPROPERTY(Category = BaseStats)
	float32 Accel = 200;

	UPROPERTY(Category = BaseStats)
	float32 AttackCooldown = 1.f;

	UPROPERTY(Category = BaseStats)
	float32 Bounciness = 0.05;

	UPROPERTY(Category = BaseStats)
	float32 AttackRange = 50;

	UPROPERTY(Category = BaseStats)
	int CoinDropAmount = 1;

	UPROPERTY(meta = (EditCondition = "Type != EZombieType::Boss", EditConditionHides), Category = Visual)
	FVector HeadScale = FVector::OneVector;

	UPROPERTY(Category = Visual)
	FVector BodyScale = FVector::OneVector;

	UPROPERTY(Category = Visual)
	FVector WeaponScale = FVector::OneVector;

	UPROPERTY(meta = (EditCondition = "Type != EZombieType::Boss", EditConditionHides), Category = Visual)
	TArray<UStaticMesh> HeadMeshList;

	UPROPERTY(Category = Visual)
	TArray<USkeletalMesh> BodyMeshList; // List of possible models for the zombie

	UPROPERTY(Category = Visual)
	TArray<UStaticMesh> AccessoryMeshList;

	UPROPERTY(Category = Animation)
	EAttackType AttackType = EAttackType::Punch;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> AttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UStaticMesh> RightWeaponList;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UStaticMesh> LeftWeaponList;

	// Might be better if I use Data Asset for this?
	UPROPERTY(BlueprintReadWrite, meta = (EditCondition = "AttackRange >= 100", EditConditionHides), Category = Projectile)
	TSubclassOf<AActor> ProjectileTemplate;

	UPROPERTY(Category = Phases)
	int NumberOfPhases = 1;

	UPROPERTY(meta = (EditCondition = "NumberOfPhases>0", EditConditionHides), Category = Phases)
	TArray<UModifierObject> Lv1Modifiers;

	UPROPERTY(meta = (EditCondition = "NumberOfPhases>1", EditConditionHides), Category = Phases)
	TArray<UModifierObject> Lv2Modifiers;

	UPROPERTY(meta = (EditCondition = "NumberOfPhases>2", EditConditionHides), Category = Phases)
	TArray<UModifierObject> Lv3Modifiers;
};
