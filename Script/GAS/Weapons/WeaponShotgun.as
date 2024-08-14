class UWeaponShotGun : UWeapon
{
	void Setup() override
	{
		SetupInner(n"RightGun");
	}

	void AttackHitCue() override
	{
		SpawnAtSocket(n"Muzzle");
		Super::AttackHitCue();
	}
};