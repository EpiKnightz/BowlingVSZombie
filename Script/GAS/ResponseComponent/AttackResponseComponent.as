class UAttackResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeAttackModifier;
	FObjectIntDelegate DOnRemoveAttackModifier;
	FFloatDelegate DOnChangeAttackCooldownModifier;

	bool InitChild() override
	{

		DOnChangeAttackModifier.BindUFunction(this, n"OnChangeAttackModifier");
		DOnRemoveAttackModifier.BindUFunction(this, n"OnRemoveAttackModifier");
		DOnChangeAttackCooldownModifier.BindUFunction(this, n"OnChangeAttackCooldownModifier");
		return true;
	}

	UFUNCTION()
	private void OnChangeAttackCooldownModifier(float Value)
	{
		// AbilitySystem.AddModifier(n"AttackCooldown", Value);
	}

	UFUNCTION()
	void OnChangeAttackModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(n"Attack", Modifier);
	}

	UFUNCTION()
	void OnRemoveAttackModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(n"Attack", Object, ID);
	}
};