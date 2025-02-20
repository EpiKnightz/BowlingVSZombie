
class UAtkCooldownStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(AttackAttrSet::FullAttackCooldown));
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