class UFreezeComponent : UStatusComponent
{
	void DoInitChildren(float iParam1, float iParam2) override
	{
		Host.speedModifier = 0;
	}

	void EndStatusEffect() override
	{
		Host.speedModifier = 1;
		Super::EndStatusEffect();
	}
}
