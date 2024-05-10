class UAdditiveMod : UModifier
{
	void DoCalculateChildren(const UAbilitySystem& AbilitySystem, float32& SourceValue) override
	{
		for (int i = 0; i < Params.Num(); i++)
		{
			SourceValue += Params[i];
		}
	}

	bool IsValidInput(float SourceValue) override
	{
		return Params.Num() > 0;
	}
};