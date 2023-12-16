struct FZombieDT
{
	UPROPERTY()
	FString Name = "Zombie";

	UPROPERTY()
	FString Description = "Zombie";

	UPROPERTY()
	int HP = 100;

	UPROPERTY()
	int Atk = 10;

	UPROPERTY()
	int Speed = 100;

	UPROPERTY()
	float AtkSpeed = 1.f;

	UPROPERTY()
	FVector Scale = FVector::OneVector;
};
