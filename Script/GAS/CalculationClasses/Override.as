class UOverride : UCalculation
{
	FBoolReturnDelegate DIsValid;

	float DoCalculateChildren(float SourceValue, TArray<float> iParam) override
	{
		return iParam[0];
	}

	// Might want to override this function for different intention when override value
	bool IsValidInput(float SourceValue, TArray<float> iParam) override
	{
		if (DIsValid.IsBound())
		{
			return DIsValid.Execute() && (iParam.Num() == 1);
		}
		else
		{
			return iParam.Num() == 1;
		}
	}
};