class USkillResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeSkillCooldownModifier;
	FObjectIntDelegate DOnRemoveSkillCooldownModifier;

	FVectorReturnDelegate DGetSkillLocation;
	FRotatorReturnDelegate DGetSkillRotation;

	bool InitChild() override
	{
		DOnChangeSkillCooldownModifier.BindUFunction(this, n"OnChangeSkillCooldownModifier");
		DOnRemoveSkillCooldownModifier.BindUFunction(this, n"OnRemoveSkillCooldownModifier");
		return true;
	}

	UFUNCTION()
	private void OnRemoveSkillCooldownModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(SkillAttrSet::SkillCooldownModifier, Object, ID);
	}

	UFUNCTION()
	private void OnChangeSkillCooldownModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(SkillAttrSet::SkillCooldownModifier, Modifier);
	}
};