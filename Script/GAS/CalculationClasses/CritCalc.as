class UCritCalc : UCalculation
{

	float DoCalculateChildren(float SourceValue) override
	{
		float CritChance = Params[0];
		float CritDamage = Params[1];
		return Math::RandRange(0, 1) <= CritChance ? SourceValue : SourceValue * CritDamage;
	}

	bool IsValidInput(float SourceValue) override
	{
		return Params.Num() == 2;
	}
};