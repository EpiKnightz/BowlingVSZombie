
class UAttackBoostComponent : UStatusComponent
{
	void DoInitChildren() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			UMultiplierMod Mod = NewObject(this, UMultiplierMod);
			Mod.Setup(ModID, FindAttrValue(n"AttackAttrSet.Attack"));
			PlayerResponse.DOnChangeAttackModifier.ExecuteIfBound(Mod);
		}
	}

	void EndStatusEffect() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			PlayerResponse.DOnRemoveAttackModifier.ExecuteIfBound(this, ModID);
		}
		Super::EndStatusEffect();
	}
};