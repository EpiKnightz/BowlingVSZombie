
class UCooldownComponent : UStatusComponent
{
	default TargetType = EStatusTargetType::Player;

	FFloatDelegate DOnChangeCooldownModifier;

	void DoInitChildren(float iParam1, float iParam2) override
	{
		auto PlayerResponse = USpeedResponeComponent::Get(Host);
		PlayerResponse.DOnChangeSpeedModifier.ExecuteIfBound(100);
	}

	void EndStatusEffect() override
	{
		auto CooldownModifier = USpeedResponeComponent::Get(Host);
		CooldownModifier.DOnChangeSpeedModifier.ExecuteIfBound(1);
		Super::EndStatusEffect();
	}
};