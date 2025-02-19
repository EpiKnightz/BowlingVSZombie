
class USkillCooldownComponent : UStatusComponent
{
	void DoInitChildren() override
	{
		auto PlayerResponse = USkillResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			UOverrideMod Mod = NewObject(this, UOverrideMod);
			Mod.SetupOnce(ModID, FindAttrValue(n"SkillAttrSet.SkillCooldownModifier"));
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