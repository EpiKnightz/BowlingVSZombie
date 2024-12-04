class UWeaponGun : UWeapon
{
	void Setup(bool RightHand = true) override
	{
		SetupInner("Gun", RightHand);
	}

	void AttackHitCue() override
	{
		SpawnAtSocket(n"Muzzle");
		Super::AttackHitCue();
	}
};