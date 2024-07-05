struct FSurvivorDT
{
	UPROPERTY()
	FGameplayTag SurvivorID;

	// FString is for friendly name
	UPROPERTY()
	FString Name = "SWAT";

	// FText is for localization, for user facing classes
	UPROPERTY()
	FText Description = FText::FromString("Description");

	UPROPERTY()
	float32 HP = 100;

	// Atk is amount of power dealing to obstacles
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
	USkeletalMesh HeadMesh;

	UPROPERTY()
	USkeletalMesh BodyMesh;

	UPROPERTY()
	USkeletalMesh AccessoryMesh;

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
}