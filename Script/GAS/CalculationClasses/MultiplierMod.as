class UMultiplierMod : UModifier
{
	void DoCalculateChildren(const ULiteAbilitySystem& AbilitySystem, float32& SourceValue) override
	{
		// for (int i = 0; i < Params.Num(); i++)
		//{
		SourceValue *= Params[0];
		//}
	}

	bool IsValidInput(float SourceValue) override
	{
		return Params.Num() > 0;
	}
};