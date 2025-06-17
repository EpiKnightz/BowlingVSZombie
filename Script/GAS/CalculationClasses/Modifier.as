class UModifier
{
	UPROPERTY()
	int ID = -1;

	UPROPERTY()
	private int Priority = 0;

	UPROPERTY()
	TArray<float32> Params;

	void Calculate(const UInteractSystem InteractSystem, float32& SourceValue)
	{
		if (IsValidInput(SourceValue))
		{
			DoCalculateChildren(InteractSystem, SourceValue);
		}
		else
		{
			PrintError("Invalid Input/Params");
		}
	}

	void DoCalculateChildren(const UInteractSystem InteractSystem, float32& SourceValue)
	{
	}

	void ReplaceParams(TArray<float32> iParams)
	{
		Params = iParams;
	}

	void SetupOnce(int iID, float32 Param)
	{
		ID = iID;
		Params.Add(Param);
	}

	void SetupMulti(int iID, TArray<float32> iParams)
	{
		ID = iID;
		Params = iParams;
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