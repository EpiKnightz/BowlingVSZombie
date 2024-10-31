class UMultiplierModObj : UModifierObject
{
	UPROPERTY()
	float32 Value;

	void AddToAbilitySystem(ULiteAbilitySystem& AbilitySystem) override
	{
		UMultiplierMod Mod = NewObject(this, UMultiplierMod);
		Mod.SetupOnce(ID, Value);
		AbilitySystem.AddModifier(AttributeName, Mod, bForceRecalculation);
	}
}