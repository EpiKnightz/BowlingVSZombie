struct FBallDT
{
	UPROPERTY()
	FString Name = "Bowling";

	UPROPERTY()
	FText Description = FText::FromString("BowlingDes");

	UPROPERTY()
	UStaticMesh BowlingMesh;

	UPROPERTY()
	float Atk = 50;

	UPROPERTY()
	float Cooldown = 1.5;

	UPROPERTY()
	float BowlingSpeed = 1000;

	UPROPERTY()
	FGameplayTag EffectTag;

	UPROPERTY()
	UNiagaraSystem StatusVFX;
};
