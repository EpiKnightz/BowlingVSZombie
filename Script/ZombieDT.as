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

	UPROPERTY(BlueprintReadWrite)
	TArray<UStaticMesh> WeaponList;
};
