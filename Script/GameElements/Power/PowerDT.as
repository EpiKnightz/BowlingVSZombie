enum EPowerTarget
{
	Bowling,
	Survivor,
	Zombie
}

struct FPowerDT
{
	UPROPERTY()
	FString Name = "Bouncer Power";

	UPROPERTY()
	FText Description = FText::FromString("After 1st bounce, Increase bowling's damage by 1.5x");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	EPowerTarget EffectType;

	UPROPERTY()
	FGameplayTagContainer AffectedAttributes;

	UPROPERTY()
	TSubclassOf<UModifier> Modifier;

	UPROPERTY()
	TArray<float32> Params;
};