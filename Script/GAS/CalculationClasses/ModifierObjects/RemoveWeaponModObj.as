class URemoveWeaponObj : UModifierObject
{
	UPROPERTY()
	bool bRemoveMainHand = true;

	void AddToAbilitySystem(UInteractSystem& InteractSystem) override
	{
		AZombie Zomb = Cast<AZombie>(InteractSystem.Owner);
		if (IsValid(Zomb))
		{
			Zomb.RemoveWeapon(bRemoveMainHand);
		}
	}
}