class UElementWeaknessStatus : UStatusComponent
{
	UPROPERTY()
	FGameplayTag Element;

	void DoInitChildren() override
	{
		auto InteractSystem = UInteractSystem::Get(GetOwner());
		if (IsValid(InteractSystem))
		{
			auto Mod = NewObject(this, ModClass);
			Mod.SetupOnce(ModID, FindAttrValue(WeaknessAttrSet::TagToFullWeakness(Element)));
			InteractSystem.AddModifier(WeaknessAttrSet::TagToWeakness(Element), Mod);
		}
	}

	void EndStatusEffect() override
	{
		auto InteractSystem = UInteractSystem::Get(GetOwner());
		if (IsValid(InteractSystem))
		{
			InteractSystem.RemoveModifier(WeaknessAttrSet::TagToWeakness(Element), this, ModID);
		}
		Super::EndStatusEffect();
	}
};