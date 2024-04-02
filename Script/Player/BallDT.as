enum EEffectType
{
	None,
	Fire,
	Chill,
	Freeze,
	Poison,
	Rupture,
	SpeedBuff
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
	float Cooldown = 1.5;

	UPROPERTY()
	int BowlingSpeed = 1000;

	UPROPERTY()
	EEffectType StatusEffect;

	UPROPERTY()
	UNiagaraSystem StatusVFX;
};
