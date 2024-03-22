class UFreezeComponent : UStatusComponent
{
	default TargetType = EStatusTargetType::Zombie;

	void DoInitChildren(float iParam1, float iParam2) override
	{
		auto SpeedResponse = USpeedResponeComponent::Get(Host);
		SpeedResponse.DOnChangeSpeedModifier.ExecuteIfBound(0);
	}

	void EndStatusEffect() override
	{
		auto SpeedResponse = USpeedResponeComponent::Get(Host);
		SpeedResponse.DOnChangeSpeedModifier.ExecuteIfBound(1);
		Super::EndStatusEffect();
	}
}
