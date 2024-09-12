enum EPowerTarget
{
	Bowling,
	Survivor,
	Zombie
}

struct FPowerDT
{
	UPROPERTY()
	FGameplayTag PowerID;

	UPROPERTY()
	FString Name = "Bouncer Power";

	UPROPERTY()
	FText Description = FText::FromString("After 1st bounce, Increase bowling's damage by 1.5x");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	int Cost = 110;

	UPROPERTY()
	EPowerTarget PowerTarget;

	UPROPERTY()
	TArray<FModifierSpec> ModifiersSpecList;
};