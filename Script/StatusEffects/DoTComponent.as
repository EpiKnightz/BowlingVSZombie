class UDoTComponent : UStatusComponent
{
	float Interval;
	float CurrentInterval = -1;
	float ParameterPerInterval;

	UDamageResponseComponent DamageResponse;

	// FInt2IntDelegate DOnDoTDamage;

	void DoInitChildren() override
	{
		Interval = FindAttrValue(n"Interval");
		// ParameterPerInterval = iParam2;
		// CurrentInterval = Interval;

		// DamageResponse = UDamageResponseComponent::Get(GetOwner());
		// if (!IsValid(DamageResponse))
		// {
		// 	EndStatusEffect();
		// }
		// UAbilitySystem abSystem = UAbilitySystem::Get(GetOwner());
		// if (IsValid(abSystem))
		// {
		// 	abSystem.AddGameplayTag(FGameplayTag::RequestGameplayTag(n"StatusEffect.Negative.Burn"));
		// }
	}

	bool ActionPerInterval()
	{
		return DamageResponse.DOnTakeDamage.ExecuteIfBound(ParameterPerInterval);
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
