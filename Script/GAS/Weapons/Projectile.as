class AProjectile : AActor
{
	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;

	UPROPERTY(DefaultComponent)
	UProjectileDataComponent ProjectileDataComp;

	// UPROPERTY(BlueprintReadOnly, Category = "Stats")
	// FProjectileData ProjectileData;
};