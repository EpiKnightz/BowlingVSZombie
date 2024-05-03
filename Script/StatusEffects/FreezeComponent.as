class UFreezeComponent : UStatusComponent
{
	void DoInitChildren() override
	{
		auto SpeedResponse = USpeedResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(0);
		}

		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DamageResponse.DOnTakeDamage.ExecuteIfBound(FindAttrValue(n"PrimaryAttrSet.Damage"));
		}
	}

	void EndStatusEffect() override
	{
		auto SpeedResponse = USpeedResponseComponent::Get(GetOwner());
		SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(1);
		Super::EndStatusEffect();
	}
}
