
class UCooldownComponent : UStatusComponent
{
	FFloatDelegate DOnChangeCooldownModifier;

	void DoInitChildren() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			PlayerResponse.DOnChangeAttackCooldownModifier.ExecuteIfBound(FindAttrValue(n"AttackAttrSet.AttackCooldown") * 0.1);
		}
	}

	void EndStatusEffect() override
	{
		auto PlayerResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			PlayerResponse.DOnChangeAttackCooldownModifier.ExecuteIfBound(1);
		}
		Super::EndStatusEffect();
	}
};