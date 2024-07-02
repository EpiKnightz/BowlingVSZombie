class UWeaponSword : UWeapon
{
	void Setup() override
	{
		SetupChild(n"RightHand");
	}

	void AttackHitCue() override
	{
		SpawnAtLocation(GetOwner().GetActorLocation());
		Super::AttackHitCue();
	}
};