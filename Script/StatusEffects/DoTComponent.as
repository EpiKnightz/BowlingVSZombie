class UDoTComponent : UStatusComponent
{
	default TargetType = ETargetType::Zombie;

	float Interval;
	float CurrentInterval = -1;
	float ParameterPerInterval;

	UDamageResponseComponent DamageResponse;

	// FInt2IntDelegate DOnDoTDamage;

	void DoInitChildren(float iParam1, float iParam2) override
	{
		Interval = iParam1;
		ParameterPerInterval = iParam2;
		CurrentInterval = Interval;

		DamageResponse = UDamageResponseComponent::Get(Host);
	}

	bool ActionPerInterval()
	{
		return DamageResponse.DOnApplyDamage.ExecuteIfBound(int(-ParameterPerInterval)) > 0;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		Super::Tick(DeltaSeconds);
		if (CurrentInterval > 0)
		{
			CurrentInterval -= DeltaSeconds;
			if (CurrentInterval <= 0)
			{
				if (ActionPerInterval())
				{
					CurrentInterval = Interval;
				}
				else
				{
					EndStatusEffect();
				}
			}
		}
	}

	void EndStatusEffect() override
	{
		CurrentInterval = -1;
		Super::EndStatusEffect();
	}
}
