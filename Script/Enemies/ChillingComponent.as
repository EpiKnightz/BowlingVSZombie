class UChillingComponent : UStatusComponent
{
	bool IsApplicable() override
	{
		UActorComponent Target = UFreezeComponent::Get(Host, n"FreezeComponent");
		return (Target == nullptr || !Target.IsActive());
	}

	void DoInitChildren(float iParam1, float iParam2) override
	{
		Host.speedModifier = 1 - (iParam1 * InitTimes);
		if (InitTimes >= iParam2)
		{
			EndStatusEffect();
			Host.CheckForStatusEffects(EStatus::Freeze);
		}
	}

	void EndStatusEffect() override
	{
		Host.speedModifier = 1;
		Super::EndStatusEffect();
	}
}
