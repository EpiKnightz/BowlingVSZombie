class USkillResponseComponent : UResponseComponent
{
	// FModDelegate DOnChangeSkillCooldownModifier;
	// FObjectIntDelegate DOnRemoveSkillCooldownModifier;

	FVectorReturnDelegate DGetSkillLocation;
	FRotatorReturnDelegate DGetSkillRotation;

	// bool InitChild() override
	//{
	// DOnChangeSkillCooldownModifier.BindUFunction(this, n"OnChangeSkillCooldownModifier");
	// DOnRemoveSkillCooldownModifier.BindUFunction(this, n"OnRemoveSkillCooldownModifier");
	// return true;
	//}

	// Do this really needed?
	// UFUNCTION()
	// private void OnRemoveSkillCooldownModifier(const UObject Object, int ID)
	//{
	// InteractSystem.RemoveModifier(SkillAttrSet::SkillCooldownModifier, Object, ID);
	//}

	// UFUNCTION()
	// private void OnChangeSkillCooldownModifier(UModifier Modifier)
	// {
	// 	InteractSystem.AddModifier(SkillAttrSet::SkillCooldownModifier, Modifier);
	// }
};