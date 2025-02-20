class UPoisonStatus : UDoTStatus
{
	void FindDamageSource() override
	{
		DamagePerInterval = FindAttrValue(PrimaryAttrSet::FullHP);
	}

	bool ActionPerInterval() override
	{
		return DamageResponse.DOnHPPercentRemoval.ExecuteIfBound(DamagePerInterval);
	}
};