class URemoveWeaponObj : UModifierObject
{
	UPROPERTY()
	bool bRemoveMainHand = true;

	void AddToAbilitySystem(ULiteAbilitySystem& AbilitySystem) override
	{
		AZombie Zomb = Cast<AZombie>(AbilitySystem.Owner);
		if (IsValid(Zomb))
		{
			Zomb.RemoveWeapon(bRemoveMainHand);
		}
	}
}