class UMultiplierResponseComponent : UResponseComponent
{
	FIntEvent EOnAddMultiplierCue;
	FFloat2Float32Delegate DCaluclateMultiplier;

	FName FirstMultiAttrName;
	FName SubsequentMultiAttrName;

	private int MultiplierCount = 0;

	bool InitChild() override
	{
		MultiplierCount = 0;
		DCaluclateMultiplier.BindUFunction(this, n"CalculateMultiplier");
		return true;
	}

	void SetAttrName(FName iFirstMultiAttrName, FName iSubsequentMultiAttrName)
	{
		FirstMultiAttrName = iFirstMultiAttrName;
		SubsequentMultiAttrName = iSubsequentMultiAttrName;
	}

	UFUNCTION()
	void AddMultiplier()
	{
		MultiplierCount++;
		EOnAddMultiplierCue.Broadcast(MultiplierCount);
	}

	UFUNCTION()
	float32 CalculateMultiplier(float32 BaseValue)
	{
		if (FirstMultiAttrName.IsNone() || SubsequentMultiAttrName.IsNone())
		{
			PrintError("MultiplierResponseComponent requires SetAttrName to be called");
			return BaseValue;
		}
		if (MultiplierCount > 0)
		{
			float32 Multiplier = InteractSystem.GetValue(FirstMultiAttrName) + (MultiplierCount - 1) * InteractSystem.GetValue(SubsequentMultiAttrName);
			return BaseValue * Multiplier;
		}
		else
		{
			return BaseValue;
		}
	}
}