class UFreezeComponent : UStatusComponent
{
	default TargetType = ETargetType::Zombie;

	void DoInitChildren(float iParam1, float iParam2) override
	{
		auto SpeedResponse = USpeedResponseComponent::Get(Host);
		SpeedResponse.DOnChangeSpeedModifier.ExecuteIfBound(0);

		auto DamageResponse = UDamageResponseComponent::Get(Host);
		DamageResponse.DOnApplyDamage.ExecuteIfBound(int(-iParam1));
	}

	void EndStatusEffect() override
	{
		auto SpeedResponse = USpeedResponseComponent::Get(Host);
		SpeedResponse.DOnChangeSpeedModifier.ExecuteIfBound(1);
		Super::EndStatusEffect();
	}
}
