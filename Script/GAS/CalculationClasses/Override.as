class UOverride : UCalculation
{
	FBoolReturnDelegate DIsValid;

	float DoCalculateChildren(float SourceValue) override
	{
		return Params[0];
	}

	// Might want to override this function for different intention when override value
	bool IsValidInput(float SourceValue) override
	{
		if (DIsValid.IsBound())
		{
			return DIsValid.Execute() && (Params.Num() == 1);
		}
		else
		{
			return Params.Num() == 1;
		}
	}
};