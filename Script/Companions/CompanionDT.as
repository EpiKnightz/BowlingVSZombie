struct FCompanionDT
{
	UPROPERTY()
	FString Name = "SpeedBuff";

	UPROPERTY()
	FText Description = FText::FromString("Faster");

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
	FVector Scale = FVector::OneVector;

	UPROPERTY()
	FGameplayTagContainer AbilitiesTags;

	UPROPERTY()
	FName WeaponSlot = n"RightPistol";
}