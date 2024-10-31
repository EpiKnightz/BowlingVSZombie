class UOverrideModObj : UModifierObject
{
	UPROPERTY()
	float32 Value;

	void AddToAbilitySystem(ULiteAbilitySystem& AbilitySystem) override
	{
		UOverrideMod Mod = NewObject(this, UOverrideMod);
		Mod.SetupOnce(ID, Value);
		AbilitySystem.AddModifier(AttributeName, Mod, bForceRecalculation);
	}
}