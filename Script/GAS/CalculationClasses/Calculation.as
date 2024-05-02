class UCalculation
{
	float Calculate(float SourceValue, TArray<float> iParam)
	{
		if (IsValidInput(SourceValue, iParam))
		{
			return DoCalculateChildren(SourceValue, iParam);
		}
		else
		{
			Print("Invalid Input");
			return SourceValue;
		}
	}

	int CalculateInt(float SourceValue, TArray<float> iParam)
	{
		return int(Calculate(SourceValue, iParam));
	}

	float DoCalculateChildren(float SourceValue, TArray<float> iParam)
	{
		// If it returns -1000, it's an error. Should use Children class only.
		return -1000;
	}

	bool IsValidInput(float SourceValue, TArray<float> iParam)
	{
		return true;
	};
};