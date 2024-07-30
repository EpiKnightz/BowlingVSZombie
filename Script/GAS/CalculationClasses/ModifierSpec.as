struct FModifierSpec
{
	UPROPERTY()
	FGameplayTag AffectedAttribute;

	UPROPERTY()
	TSubclassOf<UModifier> Modifier;

	UPROPERTY()
	TArray<float32> Params;
}