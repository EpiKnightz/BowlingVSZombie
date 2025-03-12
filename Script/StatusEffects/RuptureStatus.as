class URuptureStatus : UStatusComponent
{
	FFloatTag2BoolDelegate DOnOldApplyDamage;
	float extraDamage;

	void DoInitChildren() override
	{
		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			// DOnOldApplyDamage.BindUFunction(DamageResponse.DOnTakeDamage.UObject, DamageResponse.DOnTakeDamage.FunctionName);
			DOnOldApplyDamage = DamageResponse.DOnTakeDamage;
			DamageResponse.DOnTakeDamage.Clear();
			DamageResponse.DOnTakeDamage.BindUFunction(this, n"CustomApplyDamage");
			extraDamage = FindAttrValue(PrimaryAttrSet::FullDamage);
		}
	}

	bool IsApplicable() override
	{
		return Super::IsApplicable() && InitTimes == 0;
	}

	UFUNCTION()
	bool CustomApplyDamage(float iDamage, FGameplayTag Element)
	{
		return DOnOldApplyDamage.ExecuteIfBound(iDamage + extraDamage);
	}

	void
	EndStatusEffect() override
	{
		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DamageResponse.DOnTakeDamage.Clear();
			// DamageResponse.DOnTakeDamage.BindUFunction(DOnOldApplyDamage.UObject, DOnOldApplyDamage.FunctionName);
			DamageResponse.DOnTakeDamage = DOnOldApplyDamage;
			DOnOldApplyDamage.Clear();
		}
		Super::EndStatusEffect();
	}
}
