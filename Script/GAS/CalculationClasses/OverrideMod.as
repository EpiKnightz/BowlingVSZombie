class UOverrideMod : UModifier
{
	FBoolReturnDelegate DIsValid;

	void DoCalculateChildren(const ULiteAbilitySystem AbilitySystem, float32& SourceValue) override
	{
		SourceValue = Params[0];
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