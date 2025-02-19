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

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY(meta = (ClampMin = "1", ClampMax = "5", UIMin = "1", UIMax = "5"))
	int Star = 1;

	UPROPERTY()
	int Cost = 100;

	UPROPERTY()
	float32 HP = 100;

	UPROPERTY()
	float32 InitialRage = 0;

	UPROPERTY()
	float32 RageRegen = 4;

	UPROPERTY()
	float32 RageBonus = 10;

	UPROPERTY()
	float32 Atk = 10;

	UPROPERTY()
	float32 Speed = 0;

	UPROPERTY()
	float32 Accel = 0;

	UPROPERTY()
	float32 AttackCooldown = 1.f;

	UPROPERTY()
	float32 Bounciness = 0.05;

	UPROPERTY()
	USkeletalMesh BodyMesh;

	UPROPERTY()
	UStaticMesh HeadMesh;

	UPROPERTY()
	UStaticMesh AccessoryMesh;

	UPROPERTY()
	FVector HeadScale = FVector::OneVector;

	UPROPERTY()
	FVector BodyScale = FVector::OneVector;

	UPROPERTY()
	FVector WeaponScale = FVector::OneVector;

	UPROPERTY()
	FGameplayTagContainer AbilitiesTags;

	UPROPERTY()
	FGameplayTag WeaponTag;

	UPROPERTY()
	FGameplayTagContainer EffectTags;

	bool IsValid()
	{
		return SurvivorID.IsValid();
	}
}