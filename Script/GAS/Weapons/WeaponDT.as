struct FWeaponDT
{
	UPROPERTY()
	FGameplayTag WeaponID;

	UPROPERTY()
	FString Name = "Weapon Name";

	UPROPERTY()
	FText Description = FText::FromString("Description");

	UPROPERTY(meta = (MultiLine = true))
	FGameplayTagContainer DescriptionTags;

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY(meta = (ClampMin = "1", ClampMax = "5", UIMin = "1", UIMax = "5"))
	int Star = 1;

	UPROPERTY()
	int Cost = 90;

	UPROPERTY()
	float32 Attack = 20;

	UPROPERTY()
	UStaticMesh WeaponMesh;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem WeaponVFX;

	// The most important part of the data, determine how animation will play and how the attack hit will notify
	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage AttackAnim;

	UPROPERTY()
	FGameplayTag DefaultAttackAbility;

	UPROPERTY()
	FGameplayTagContainer EffectTags;

	bool IsValid()
	{
		return WeaponID.IsValid();
	}
};