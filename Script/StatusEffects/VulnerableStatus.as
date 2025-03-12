class UVulnerableStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto AbilitySystem = ULiteAbilitySystem::Get(GetOwner());
		if (IsValid(AbilitySystem))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(PrimaryAttrSet::FullDamage));
			AbilitySystem.AddModifier(PrimaryAttrSet::Damage, Mod, false);
		}
	}

	void EndStatusEffect() override
	{
		auto AbilitySystem = ULiteAbilitySystem::Get(GetOwner());
		if (IsValid(AbilitySystem))
		{
			AbilitySystem.RemoveModifier(PrimaryAttrSet::Damage, this, ModID);
		}
		Super::EndStatusEffect();
	}
};