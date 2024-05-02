class UWoundedComponent : UStatusComponent
{
	FFloat2BoolDelegate DOnOldApplyDamage;
	float extraDamage;

	void DoInitChildren() override
	{
		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DOnOldApplyDamage.BindUFunction(DamageResponse.DOnApplyDamage.UObject, DamageResponse.DOnApplyDamage.FunctionName);
			DamageResponse.DOnApplyDamage.Clear();
			DamageResponse.DOnApplyDamage.BindUFunction(this, n"CustomApplyDamage");
			extraDamage = FindAttrValue(n"PrimaryAttrSet.Damage");
		}
	}

	bool IsApplicable() override
	{
		return Super::IsApplicable() && InitTimes == 0;
	}

	UFUNCTION()
	bool CustomApplyDamage(float iDamage)
	{
		return DOnOldApplyDamage.ExecuteIfBound(iDamage - extraDamage);
	}

	void
	EndStatusEffect() override
	{
		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DamageResponse.DOnApplyDamage.Clear();
			DamageResponse.DOnApplyDamage.BindUFunction(DOnOldApplyDamage.UObject, DOnOldApplyDamage.FunctionName);
			DOnOldApplyDamage.Clear();
		}
		Super::EndStatusEffect();
	}
}
