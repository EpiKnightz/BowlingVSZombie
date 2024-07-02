class UWeaponGun : UWeapon
{
	void Setup() override
	{
		SetupChild(n"RightGun");
	}

	void AttackHitCue() override
	{
		SpawnAtSocket(n"Muzzle");
		Super::AttackHitCue();
	}
};