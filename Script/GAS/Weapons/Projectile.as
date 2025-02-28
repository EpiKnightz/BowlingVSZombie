class AProjectile : AActor
{
	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default InitialLifeSpan = 5;

	UPROPERTY(DefaultComponent)
	UProjectileDataComponent ProjectileDataComp;

	// UPROPERTY(BlueprintReadOnly, Category = "Stats")
	// FProjectileData ProjectileData;
};