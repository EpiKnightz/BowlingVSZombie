class UBurningComponent : UDoTComponent
{
	void FindDamageSource() override
	{
		DamagePerInterval = FindAttrValue(n"PrimaryAttrSet.Damage");
	}
};