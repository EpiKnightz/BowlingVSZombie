class UDoTStatus : UStatusComponent
{
	float Interval;
	float CurrentInterval = -1;
	float DamagePerInterval;

	UDamageResponseComponent DamageResponse;

	// FInt2IntDelegate DOnDoTDamage;

	void DoInitChildren() override
	{
		Interval = FindAttrValue(DurationAttrSet::FullInterval);
		FindDamageSource();
		CurrentInterval = Interval;

		DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (!IsValid(DamageResponse)
			|| Interval == AbilitySystem::INVALID_VALUE
			|| DamagePerInterval == AbilitySystem::INVALID_VALUE)
		{
			EndStatusEffect();
		}
	}

	void FindDamageSource()
	{
		DamagePerInterval = FindAttrValue(AttackAttrSet::FullAttack);
	}

	bool ActionPerInterval()
	{
		return DamageResponse.DOnTakeDamage.ExecuteIfBound(DamagePerInterval);
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
