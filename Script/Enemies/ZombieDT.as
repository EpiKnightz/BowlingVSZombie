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

	UPROPERTY()
	float32 HP = 100;

	// Atk is amount of power dealing to obstacles
	UPROPERTY()
	float32 Atk = 10;

	UPROPERTY()
	float32 Speed = 100;

	UPROPERTY()
	float32 Accel = 200;

	UPROPERTY()
	float32 AttackCooldown = 1.f;

	UPROPERTY()
	float32 Bounciness = 0.05;

	UPROPERTY()
	int CoinDropAmount = 1;

	UPROPERTY(meta = (EditCondition = "Type != EZombieType::Boss", EditConditionHides))
	FVector HeadScale = FVector::OneVector;

	UPROPERTY()
	FVector BodyScale = FVector::OneVector;

	UPROPERTY()
	FVector WeaponScale = FVector::OneVector;

	UPROPERTY(meta = (EditCondition = "Type != EZombieType::Boss", EditConditionHides))
	TArray<UStaticMesh> HeadMeshList;

	UPROPERTY()
	TArray<USkeletalMesh> BodyMeshList; // List of possible models for the zombie

	UPROPERTY()
	TArray<UStaticMesh> AccessoryMeshList;

	UPROPERTY()
	ESocketType RightSocketType;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> RightWeaponList;

	UPROPERTY()
	ESocketType LeftSocketType;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> LeftWeaponList;

	UPROPERTY()
	int NumberOfPhases = 1;

	UPROPERTY(meta = (EditCondition = "NumberOfPhases>0", EditConditionHides))
	TArray<UModifierObject> Lv1Modifiers;

	UPROPERTY(meta = (EditCondition = "NumberOfPhases>1", EditConditionHides))
	TArray<UModifierObject> Lv2Modifiers;

	UPROPERTY(meta = (EditCondition = "NumberOfPhases>2", EditConditionHides))
	TArray<UModifierObject> Lv3Modifiers;
};
