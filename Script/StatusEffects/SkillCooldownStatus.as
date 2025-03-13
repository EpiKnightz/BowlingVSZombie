
class USkillCooldownStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto AbilitySystem = ULiteAbilitySystem::Get(GetOwner());
		if (IsValid(AbilitySystem))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(SkillAttrSet::FullSkillCooldownModifier));
			// PlayerResponse.DOnChangeSkillCooldownModifier.ExecuteIfBound(Mod);
			AbilitySystem.AddModifier(SkillAttrSet::SkillCooldownModifier, Mod);
		}
	}

	void EndStatusEffect() override
	{
		auto AbilitySystem = ULiteAbilitySystem::Get(GetOwner());
		if (IsValid(AbilitySystem))
		{
			AbilitySystem.RemoveModifier(SkillAttrSet::SkillCooldownModifier, this, ModID);
		}
		Super::EndStatusEffect();
	}
};