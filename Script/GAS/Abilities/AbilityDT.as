struct FAbilityDT
{
	UPROPERTY()
	FGameplayTag AbilityID;

	UPROPERTY()
	FString Name = "Ability Name";

	UPROPERTY()
	FText Description = FText::FromString("Description");

	UPROPERTY()
	TSubclassOf<AActor> ActorTemplate;
};