struct FSurvivorDT
{
	UPROPERTY()
	FGameplayTag SurvivorID;

	UPROPERTY()
	FString Name = "SWAT";

	UPROPERTY()
	FText Description = FText::FromString("Description");

	UPROPERTY()
	int HP = 100;

	// Atk is amount of power dealing to obstacles
	UPROPERTY()
	int Atk = 10;

	UPROPERTY()
	int Speed = 100;

	UPROPERTY()
	int Accel = 200;

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
}