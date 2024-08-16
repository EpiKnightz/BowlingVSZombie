enum EAbilityTriggerType
{
	OnOverlap,
	OnOverlapMarkTarget,
	OnTimeLoop,
	OnSetup,
	None,
}

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
	EAbilityTriggerType TriggerType = EAbilityTriggerType::None;

	UPROPERTY()
	float TriggerParam = 0;

	UPROPERTY()
	TSubclassOf<AActor> ActorTemplate;

	UPROPERTY()
	FGameplayTagContainer AbilityTags;
};