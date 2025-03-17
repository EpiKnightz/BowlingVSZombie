class AProjectile : AActor
{
	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default InitialLifeSpan = 5;

	UPROPERTY(DefaultComponent)
	UProjectileDataComponent ProjectileDataComp;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Untargetable;

	void RangeToLifeTime(float Range)
	{
		SetLifeSpan(Range / MovementComp.InitialSpeed);
	}
};