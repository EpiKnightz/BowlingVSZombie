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

struct FZombieDT
{
	UPROPERTY()
	FString Name = "Zombie";

	UPROPERTY()
	FString Description = "Zombie";

	UPROPERTY()
	int HP = 100;

	// Atk is amount of power dealing to obstacles
	UPROPERTY()
	int Atk = 10;

	// Dmg is amount of power dealing to Player's HP
	UPROPERTY()
	int Dmg = 10;

	UPROPERTY()
	int Speed = 100;

	UPROPERTY()
	float AtkSpeed = 1.f;

	UPROPERTY()
	FVector Scale = FVector::OneVector;

	UPROPERTY()
	TArray<USkeletalMesh> ZombieModelList;

	UPROPERTY()
	ESocketType RightSocketType;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> RightWeaponList;

	UPROPERTY()
	ESocketType LeftSocketType;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> LeftWeaponList;
};
