class UReplaceDamageColor : UModifierObject
{
	UPROPERTY()
	FLinearColor DamageColor;

	void AddToAbilitySystem(ULiteAbilitySystem& AbilitySystem) override
	{
		AZombie Zomb = Cast<AZombie>(AbilitySystem.Owner);
		if (IsValid(Zomb))
		{
			Zomb.ChangeDamagedColor(DamageColor);
		}
	}
};