class UPoisonComponent : UDoTComponent
{
	void FindDamageSource() override
	{
		DamagePerInterval = FindAttrValue(n"PrimaryAttrSet.HP");
	}

	bool ActionPerInterval() override
	{
		return DamageResponse.DOnHPPercentRemoval.ExecuteIfBound(DamagePerInterval);
	}
};