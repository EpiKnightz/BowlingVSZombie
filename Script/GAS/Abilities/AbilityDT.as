struct FAbilityDT
{
	UPROPERTY(EditDefaultsOnly, Category = Ability, meta = (Categories = "Ability"))
	FGameplayTag AbilityID;

	UPROPERTY()
	FString Name = "Ability Name";

	UPROPERTY(meta = (MultiLine = true))
	FText Description = FText::FromString("Description");

	UPROPERTY()
	FGameplayTagContainer DescriptionTags;

	UPROPERTY(meta = (ClampMin = "1", ClampMax = "5", UIMin = "1", UIMax = "5"))
	int Star = 1;

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	int Cost = 80;

	UPROPERTY()
	TSubclassOf<UTrigger> TriggerClass;

	UPROPERTY()
	float TriggerParam = 0;

	UPROPERTY()
	TSubclassOf<UAbility> AbilityClass;

	UPROPERTY(EditDefaultsOnly, Category = AbilityParam, meta = (Categories = "AbilityParam,Status"))
	TMap<FGameplayTag, float> AbilityParams;

	UPROPERTY()
	TSubclassOf<AActor> ActorTemplate;

	UPROPERTY()
	FGameplayTagContainer AbilityTags;
};