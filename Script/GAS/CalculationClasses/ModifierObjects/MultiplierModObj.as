class UMultiplierModObj : UModifierObject
{
	UPROPERTY()
	float32 Value;

	void AddToAbilitySystem(UInteractSystem& InteractSystem) override
	{
		UMultiplierMod Mod = NewObject(this, UMultiplierMod);
		Mod.SetupOnce(ID, Value);
		InteractSystem.AddModifier(AttributeName, Mod, bForceRecalculation);
	}
}