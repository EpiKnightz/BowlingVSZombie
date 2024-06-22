class UModifier
{
	UPROPERTY()
	int ID = -1;

	UPROPERTY()
	private int Priority = 0;

	TArray<float32> Params;

	void Calculate(const ULiteAbilitySystem& AbilitySystem, float32& SourceValue)
	{
		if (IsValidInput(SourceValue))
		{
			DoCalculateChildren(AbilitySystem, SourceValue);
		}
		else
		{
			PrintError("Invalid Input");
		}
	}

	void DoCalculateChildren(const ULiteAbilitySystem& AbilitySystem, float32& SourceValue)
	{
	}

	void AddParams(TArray<float32> iParams)
	{
		Params = iParams;
	}

	void Setup(int iID, float32 Param)
	{
		ID = iID;
		Params.Add(Param);
	}

	bool IsValidInput(float SourceValue)
	{
		return true;
	};

	int opCmp(UModifier Other) const
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