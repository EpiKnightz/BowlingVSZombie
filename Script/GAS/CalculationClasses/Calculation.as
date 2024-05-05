class UCalculation
{
	UPROPERTY()
	int Priority = 0;

	TArray<float> Params;

	float Calculate(float SourceValue)
	{
		if (IsValidInput(SourceValue))
		{
			return DoCalculateChildren(SourceValue);
		}
		else
		{
			Print("Invalid Input");
			return SourceValue;
		}
	}

	int CalculateInt(float SourceValue)
	{
		return int(Calculate(SourceValue));
	}

	float DoCalculateChildren(float SourceValue)
	{
		// If it returns -1000, it's an error. Should use Children class only.
		return -1000;
	}

	void AddParams(TArray<float> iParams)
	{
		Params = iParams;
	}

	bool IsValidInput(float SourceValue)
	{
		return true;
	};

	int opCmp(UCalculation Other) const
	{
		if (Priority < Other.Priority)
		{
			return -1;
		}
		else if (Priority > Other.Priority)
		{
			return 1;
		}
		return 0;
	}
};