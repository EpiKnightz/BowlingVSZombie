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
	FVector HeadScale = FVector::OneVector;

	UPROPERTY()
	FVector BodyScale = FVector::OneVector;

	UPROPERTY()
	FVector WeaponScale = FVector::OneVector;

	UPROPERTY()
	int CoinDropAmount = 1;

	UPROPERTY()
	TArray<USkeletalMesh> BodyMeshList; // List of possible models for the zombie

	UPROPERTY()
	TArray<UStaticMesh> HeadMeshList;

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
};
