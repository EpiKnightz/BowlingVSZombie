struct FBallDT
{
	UPROPERTY()
	FGameplayTag BowlingID;

	UPROPERTY()
	FString Name = "Bowling";

	UPROPERTY()
	FText Description = FText::FromString("BowlingDes");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY(meta = (ClampMin = "1", ClampMax = "5", UIMin = "1", UIMax = "5"))
	int Star = 1;

	UPROPERTY()
	int Cost = 120;

	UPROPERTY()
	UStaticMesh BowlingMesh;

	UPROPERTY()
	float32 Atk = 50;

	UPROPERTY()
	float32 Cooldown = 1.5;

	UPROPERTY()
	float32 BowlingSpeed = 1000;

	UPROPERTY()
	float32 Bounciness = 0.8;

	UPROPERTY()
	bool bIsPiercable = false;

	UPROPERTY()
	FGameplayTagContainer EffectTags;

	UPROPERTY()
	UNiagaraSystem StatusVFX;
};
