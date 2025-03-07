class UWeaponGun : UWeapon
{
	void Setup(bool MainHand = true) override
	{
		SetupInner("Gun", MainHand);
	}

	void AttackHitCue() override
	{
		SpawnAtSocket(n"Muzzle");
		Super::AttackHitCue();
	}
};