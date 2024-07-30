
class UCooldownComponent : UStatusComponent
{
	void DoInitChildren() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			UMultiplierMod Mod = NewObject(this, UMultiplierMod);
			Mod.SetupOnce(ModID, FindAttrValue(n"AttackAttrSet.AttackCooldown"));
			PlayerResponse.DOnChangeAttackCooldownModifier.ExecuteIfBound(Mod);
		}
	}

	void EndStatusEffect() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			PlayerResponse.DOnRemoveAttackCooldownModifier.ExecuteIfBound(this, ModID);
		}
		Super::EndStatusEffect();
	}
};