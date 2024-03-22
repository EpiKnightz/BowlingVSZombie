class UChillingComponent : UStatusComponent
{
	default TargetType = EStatusTargetType::Zombie;

	bool IsApplicable() override
	{
		UActorComponent Target = UFreezeComponent::Get(Host);
		return Super::IsApplicable() && (Target == nullptr || !Target.IsActive());
	}

	void DoInitChildren(float iParam1, float iParam2) override
	{
		auto SpeedResponse = USpeedResponeComponent::Get(Host);
		SpeedResponse.DOnChangeSpeedModifier.ExecuteIfBound(1 - (iParam1 * InitTimes));
		if (InitTimes >= iParam2)
		{
			EndStatusEffect();
			auto StatusResponse = UStatusResponseComponent::Get(Host);
			StatusResponse.DOnApplyStatus.ExecuteIfBound(EDamageType::Freeze);
		}
	}

	void EndStatusEffect() override
	{
		auto SpeedResponse = USpeedResponeComponent::Get(Host);
		SpeedResponse.DOnChangeSpeedModifier.ExecuteIfBound(1);
		Super::EndStatusEffect();
	}
}
