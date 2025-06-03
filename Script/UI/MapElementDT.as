enum EMapElement
{
	House,
	School,	  // Ability/Skill
	Station,  // Weapon
	Store,	  // Supplies
	Workshop, // Upgrade
	Church,	  // Survivor
	Elite,	  // Power?
	Boss,	  // Mythic Power
	None,	  // Error type
};
struct FMapElementDT
{
	UPROPERTY()
	FGameplayTag MapElementID;

	UPROPERTY()
	FString Name = "House";

	UPROPERTY(meta = (MultiLine = true))
	FText Description = FText::FromString("House Des");

	UPROPERTY()
	EMapElement Type;

	UPROPERTY()
	FGameplayTagContainer DescriptionTags;

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	UTexture2D InactiveIcon;
};
