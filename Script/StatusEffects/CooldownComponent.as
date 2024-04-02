
class UCooldownComponent : UStatusComponent
{
	default TargetType = ETargetType::Player;

	FFloatDelegate DOnChangeCooldownModifier;

	void DoInitChildren(float iParam1, float iParam2) override
	{
		auto PlayerResponse = USpeedResponseComponent::Get(Host);
		PlayerResponse.DOnChangeSpeedModifier.ExecuteIfBound(iParam1);
	}

	void EndStatusEffect() override
	{
		auto CooldownModifier = USpeedResponseComponent::Get(Host);
		CooldownModifier.DOnChangeSpeedModifier.ExecuteIfBound(1);
		Super::EndStatusEffect();
	}
};