class UCritMod : UModifier
{

	void DoCalculateChildren(const UAbilitySystem& AbilitySystem, float32& SourceValue) override
	{
		float CritChance = Params[0];
		float CritDamage = Params[1];
		SourceValue = Math::RandRange(0, 1) <= CritChance ? SourceValue : float32(SourceValue * CritDamage);
	}

	bool IsValidInput(float SourceValue) override
	{
		return Params.Num() == 2;
	}
};