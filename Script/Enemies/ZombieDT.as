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
	FText Description = FText::FromString("Zombie");

	UPROPERTY()
	int HP = 100;

	// Atk is amount of power dealing to obstacles
	UPROPERTY()
	int Atk = 10;

	UPROPERTY()
	int Speed = 100;

	UPROPERTY()
	int Accel = 200;

	UPROPERTY()
	float32 AttackCooldown = 1.f;

	UPROPERTY()
	float32 Bounciness = 0.05;

	UPROPERTY()
	FVector Scale = FVector::OneVector;

	UPROPERTY()
	int CoinDropAmount = 1;

	UPROPERTY()
	TArray<USkeletalMesh> HeadMeshList;

	UPROPERTY()
	TArray<USkeletalMesh> BodyMeshList; // List of possible models for the zombie

	UPROPERTY()
	TArray<USkeletalMesh> AccessoryMeshList;

	UPROPERTY()
	ESocketType RightSocketType;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> RightWeaponList;

	UPROPERTY()
	ESocketType LeftSocketType;

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> LeftWeaponList;
};
