struct FAbilityDT
{
	UPROPERTY()
	FGameplayTag AbilityID;

	UPROPERTY()
	FString Name = "Ability Name";

	UPROPERTY()
	FText Description = FText::FromString("Description");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	TSubclassOf<AActor> ActorTemplate;

	UPROPERTY()
	FGameplayTagContainer AbilityTags;
};