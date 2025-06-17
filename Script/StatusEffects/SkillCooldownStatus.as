
class USkillCooldownStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto InteractSystem = UInteractSystem::Get(GetOwner());
		if (IsValid(InteractSystem))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(SkillAttrSet::FullSkillCooldownModifier));
			// PlayerResponse.DOnChangeSkillCooldownModifier.ExecuteIfBound(Mod);
			InteractSystem.AddModifier(SkillAttrSet::SkillCooldownModifier, Mod);
		}
	}

	void EndStatusEffect() override
	{
		auto InteractSystem = UInteractSystem::Get(GetOwner());
		if (IsValid(InteractSystem))
		{
			InteractSystem.RemoveModifier(SkillAttrSet::SkillCooldownModifier, this, ModID);
		}
		Super::EndStatusEffect();
	}
};