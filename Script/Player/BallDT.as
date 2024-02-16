enum EStatus
{
	None,
	Fire,
	Chill,
	Freeze,
	Poison,
	Rupture
}

struct FBallDT
{
	UPROPERTY()
	FString Name = "Bowling";

	UPROPERTY()
	FString Description = "BowlingDes";

	UPROPERTY()
	UStaticMesh BowlingMesh;

	UPROPERTY()
	int Atk = 50;

	UPROPERTY()
	EStatus StatusEffect;

	UPROPERTY()
	UNiagaraSystem StatusVFX;
};
