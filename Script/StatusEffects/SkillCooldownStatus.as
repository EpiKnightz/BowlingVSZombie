
class USkillCooldownStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto PlayerResponse = USkillResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(SkillAttrSet::FullSkillCooldownModifier));
			PlayerResponse.DOnChangeSkillCooldownModifier.ExecuteIfBound(Mod);
		}
	}

	void EndStatusEffect() override
	{
		auto PlayerResponse = USkillResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			PlayerResponse.DOnRemoveSkillCooldownModifier.ExecuteIfBound(this, ModID);
		}
		Super::EndStatusEffect();
	}
};