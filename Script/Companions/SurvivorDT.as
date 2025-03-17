struct FSurvivorDT
{
	UPROPERTY()
	FGameplayTag SurvivorID;

	// FString is for friendly name
	UPROPERTY()
	FString Name = "SWAT";

	// FText is for localization, for user facing classes
	UPROPERTY(meta = (MultiLine = true))
	FText Description = FText::FromString("Description");

	UPROPERTY()
	FGameplayTagContainer DescriptionTags;

	UPROPERTY(Category = Skills)
	FGameplayTagContainer AbilitiesTags;

	UPROPERTY(Category = Skills)
	FGameplayTag WeaponTag;

	UPROPERTY(Category = Skills)
	FGameplayTagContainer EffectTags;

	UPROPERTY(Category = BaseStats)
	float32 HP = 100;

	UPROPERTY(Category = BaseStats)
	float32 Attack = 10;

	UPROPERTY(Category = BaseStats)
	float32 AttackCooldown = 1.f;

	UPROPERTY(Category = BaseStats)
	float32 InitialRage = 0;

	UPROPERTY(Category = BaseStats)
	float32 RageRegen = 4;

	UPROPERTY(Category = BaseStats)
	float32 RageBonus = 10;

	UPROPERTY(Category = BaseStats)
	float32 Speed = 0;

	UPROPERTY(Category = BaseStats)
	float32 Accel = 0;

	UPROPERTY(Category = BaseStats)
	float32 Bounciness = 0.05;
	UPROPERTY(Category = Appearance)
	UTexture2D Icon;
	UPROPERTY(Category = Appearance)
	USkeletalMesh BodyMesh;

	UPROPERTY(Category = Appearance)
	UStaticMesh HeadMesh;

	UPROPERTY(Category = Appearance)
	UStaticMesh AccessoryMesh;

	UPROPERTY(Category = Appearance)
	FVector HeadScale = FVector::OneVector;

	UPROPERTY(Category = Appearance)
	FVector BodyScale = FVector::OneVector;

	UPROPERTY(Category = Appearance)
	FVector WeaponScale = FVector::OneVector;

	UPROPERTY(meta = (ClampMin = "1", ClampMax = "5", UIMin = "1", UIMax = "5"), Category = Metagame)
	int Star = 1;

	UPROPERTY(Category = Metagame)
	int Cost = 100;

	bool IsValid()
	{
		return SurvivorID.IsValid();
	}
}