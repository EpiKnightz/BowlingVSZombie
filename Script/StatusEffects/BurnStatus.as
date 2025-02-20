// Different from DOT, this is direct HP removal per interval
class UBurnStatus : UDoTStatus
{
	void FindDamageSource() override
	{
		DamagePerInterval = FindAttrValue(PrimaryAttrSet::Damage);
	}

	bool ActionPerInterval() override
	{
		return DamageResponse.DOnHPRemoval.ExecuteIfBound(DamagePerInterval);
	}
};