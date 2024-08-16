class UWeaponGun : UWeapon
{
	void Setup() override
	{
		SetupInner(n"RightHand");
	}

	void AttackHitCue() override
	{
		SpawnAtSocket(n"Muzzle");
		Super::AttackHitCue();
	}
};