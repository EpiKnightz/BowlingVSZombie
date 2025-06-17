class UOverrideModObj : UModifierObject
{
	UPROPERTY()
	float32 Value;

	void AddToAbilitySystem(UInteractSystem& InteractSystem) override
	{
		UOverrideMod Mod = NewObject(this, UOverrideMod);
		Mod.SetupOnce(ID, Value);
		InteractSystem.AddModifier(AttributeName, Mod, bForceRecalculation);
	}
}