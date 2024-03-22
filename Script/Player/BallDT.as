enum EDamageType
{
	None,
	Fire,
	Chill,
	Freeze,
	Poison,
	Rupture,
	Buff
}

struct FBallDT
{
	UPROPERTY()
	FString Name = "Bowling";

	UPROPERTY()
	FText Description = FText::FromString("BowlingDes");

	UPROPERTY()
	UStaticMesh BowlingMesh;

	UPROPERTY()
	int Atk = 50;

	UPROPERTY()
	EDamageType StatusEffect;

	UPROPERTY()
	UNiagaraSystem StatusVFX;
};
