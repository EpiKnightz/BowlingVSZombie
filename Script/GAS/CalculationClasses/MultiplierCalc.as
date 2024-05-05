class UMultiplierCalc : UCalculation
{

	float DoCalculateChildren(float SourceValue) override
	{
		float Result = SourceValue;
		for (int i = 0; i < Params.Num(); i++)
		{
			Result *= Params[i];
		}
		return Result;
	}

	bool IsValidInput(float SourceValue) override
	{
		return Params.Num() > 0;
	}
};