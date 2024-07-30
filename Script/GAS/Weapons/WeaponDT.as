struct FWeaponDT
{
	UPROPERTY()
	FGameplayTag WeaponID;

	UPROPERTY()
	FString Name = "Weapon Name";

	UPROPERTY()
	FText Description = FText::FromString("Description");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	UStaticMesh WeaponMesh;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem WeaponVFX;

	// The most important part of the data, determine how animation will play and how the attack hit will notify
	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage AttackAnim;
};