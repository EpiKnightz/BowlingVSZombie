class UFreezeComponent : UStatusComponent
{
	FFloatDelegate DOnChangeSpeedModifier;

	void DoInitChildren(float iParam1, float iParam2) override
	{
		DOnChangeSpeedModifier.ExecuteIfBound(0);
	}

	void EndStatusEffect() override
	{
		DOnChangeSpeedModifier.ExecuteIfBound(1);
		Super::EndStatusEffect();
	}
}
