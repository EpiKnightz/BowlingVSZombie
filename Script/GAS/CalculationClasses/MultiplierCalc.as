class UMultiplierCalc : UCalculation
{

	float DoCalculateChildren(float SourceValue, TArray<float> iParam) override
	{
		float Result = SourceValue;
		for (int i = 0; i < iParam.Num(); i++)
		{
			Result *= iParam[i];
		}
		return Result;
	}

	bool IsValidInput(float SourceValue, TArray<float> iParam) override
	{
		return iParam.Num() > 0;
	}
};