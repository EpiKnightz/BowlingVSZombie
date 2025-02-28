// Different from DOT, this is direct HP removal per interval
class UBurnStatus : UDoTStatus
{
	void FindDamageSource() override
	{
		DamagePerInterval = FindAttrValue(PrimaryAttrSet::FullDamage);
	}

	bool ActionPerInterval() override
	{
		return DamageResponse.DOnHPRemoval.ExecuteIfBound(DamagePerInterval);
	}
};