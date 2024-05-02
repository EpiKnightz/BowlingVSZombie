class UCritCalc : UCalculation
{

	float DoCalculateChildren(float SourceValue, TArray<float> iParam) override
	{
		float CritChance = iParam[0];
		float CritDamage = iParam[1];
		return Math::RandRange(0, 1) <= CritChance ? SourceValue : SourceValue * CritDamage;
	}

	bool IsValidInput(float SourceValue, TArray<float> iParam) override
	{
		return iParam.Num() == 2;
	}
};