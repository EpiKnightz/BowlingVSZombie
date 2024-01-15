enum EStatus
{
	None,
	Fire,
	Ice
}

struct FBallDT
{
	UPROPERTY()
	FString Name = "Bowling";

	UPROPERTY()
	FString Description = "BowlingDes";

	UPROPERTY()
	int Atk = 50;

	UPROPERTY()
	EStatus StatusEffect;
};
