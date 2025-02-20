
class UAttackModStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			UMultiplierMod Mod = NewObject(this, UMultiplierMod);
			Mod.SetupOnce(ModID, FindAttrValue(AttackAttrSet::FullAttack));
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