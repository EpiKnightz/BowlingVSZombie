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

	UPROPERTY(meta = (MultiLine = true))
	FText Description = FText::FromString("After 1st bounce, Increase bowling's damage by 1.5x");

	UPROPERTY()
	FGameplayTagContainer DescriptionTags;

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY(meta = (ClampMin = "1", ClampMax = "5", UIMin = "1", UIMax = "5"))
	int Star = 1;

	UPROPERTY()
	int Cost = 110;

	UPROPERTY()
	EPowerTarget PowerTarget;

	UPROPERTY()
	TArray<FModifierSpec> ModifiersSpecList;
};