class UWeaponPistol : UWeaponGun
{
	void Setup() override
	{
		SetupChild(n"RightPistol");
	}
};