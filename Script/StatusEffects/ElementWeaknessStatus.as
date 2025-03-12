class UElementWeaknessStatus : UStatusComponent
{
	UPROPERTY()
	FGameplayTag Element;

	void DoInitChildren() override
	{
		auto AbilitySystem = ULiteAbilitySystem::Get(GetOwner());
		if (IsValid(AbilitySystem))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(WeaknessAttrSet::TagToFullWeakness(Element)));
			AbilitySystem.AddModifier(WeaknessAttrSet::TagToWeakness(Element), Mod);
		}
	}

	void EndStatusEffect() override
	{
		auto AbilitySystem = ULiteAbilitySystem::Get(GetOwner());
		if (IsValid(AbilitySystem))
		{
			AbilitySystem.RemoveModifier(WeaknessAttrSet::TagToWeakness(Element), this, ModID);
		}
		Super::EndStatusEffect();
	}
};