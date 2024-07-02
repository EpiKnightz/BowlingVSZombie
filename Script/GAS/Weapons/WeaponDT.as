struct FWeaponDT
{
	UPROPERTY()
	FGameplayTag WeaponID;

	UPROPERTY()
	FString Name = "Weapon Name";

	UPROPERTY()
	FText Description = FText::FromString("Description");

	UPROPERTY()
	UStaticMesh WeaponMesh;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem WeaponVFX;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage AttackAnim;
};