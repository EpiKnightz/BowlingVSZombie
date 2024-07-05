class AProjectile : AActor
{
	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;

	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	FProjectileData ProjectileData;
};