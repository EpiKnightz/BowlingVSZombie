class UAttackResponseComponent : UActorComponent
{
	FModDelegate DOnChangeAttackModifier;
	FObjectIntDelegate DOnRemoveAttackModifier;
	FFloatDelegate DOnChangeAttackCooldownModifier;

	private UAbilitySystem AbilitySystem;

	UFUNCTION()
	void Initialize(UAbilitySystem iAbilitySystem)
	{
		if (IsValid(iAbilitySystem))
		{
			AbilitySystem = iAbilitySystem;
			DOnChangeAttackModifier.BindUFunction(this, n"OnChangeAttackModifier");
			DOnRemoveAttackModifier.BindUFunction(this, n"OnRemoveAttackModifier");
		}
		else
		{
			PrintError("DamageResponseComponent: AbilitySystem is invalid.");
			ForceDestroyComponent();
		}
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