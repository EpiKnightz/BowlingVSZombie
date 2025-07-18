class UWeaponSword : UWeapon
{
	void Setup(bool MainHand = true) override
	{
		SetupInner("Hand", MainHand);
	}

	void AttackHitCue() override
	{
		SpawnAtLocation(GetOwner().GetActorLocation());
		Super::AttackHitCue();
	}

	void ResetTransform() override
	{
		// Sword anchor is different from gun, so ZYaw = 180
		GetOwner().SetActorLocationAndRotation(FVector(0, 0, 50), FRotator(0, 180, 90));
		GetOwner().SetActorScale3D(FVector::OneVector * 2);
	}
};