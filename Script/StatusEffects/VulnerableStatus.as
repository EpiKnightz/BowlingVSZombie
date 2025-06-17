class UVulnerableStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto InteractSystem = UInteractSystem::Get(GetOwner());
		if (IsValid(InteractSystem))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(PrimaryAttrSet::FullDamage));
			InteractSystem.AddModifier(PrimaryAttrSet::Damage, Mod, false);
		}
	}

	void EndStatusEffect() override
	{
		auto InteractSystem = UInteractSystem::Get(GetOwner());
		if (IsValid(InteractSystem))
		{
			InteractSystem.RemoveModifier(PrimaryAttrSet::Damage, this, ModID);
		}
		Super::EndStatusEffect();
	}
};