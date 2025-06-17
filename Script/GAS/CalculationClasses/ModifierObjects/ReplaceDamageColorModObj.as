class UReplaceDamageColor : UModifierObject
{
	UPROPERTY()
	FLinearColor DamageColor;

	void AddToAbilitySystem(UInteractSystem& InteractSystem) override
	{
		AZombie Zomb = Cast<AZombie>(InteractSystem.Owner);
		if (IsValid(Zomb))
		{
			Zomb.ChangeDamagedColor(DamageColor);
		}
	}
};