
class UCooldownComponent : UStatusComponent
{
	FFloatDelegate DOnChangeCooldownModifier;

	void DoInitChildren() override
	{
		auto PlayerResponse = USpeedResponseComponent::Get(GetOwner());
		if (IsValid(PlayerResponse))
		{
			PlayerResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(FindAttrValue(n"AttackAttrSet.AttackCooldown"));
		}
	}

	void EndStatusEffect() override
	{
		auto CooldownModifier = USpeedResponseComponent::Get(GetOwner());
		if (IsValid(CooldownModifier))
		{
			CooldownModifier.DOnChangeMoveSpeedModifier.ExecuteIfBound(1);
		}
		Super::EndStatusEffect();
	}
};