class USkillAbility : UAbility
{

	float CalculateSkillAttack()
	{
		float BaseSkillAttack, SkillAttackModifier = 0;
		if (!AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_BaseSkillAttack, BaseSkillAttack))
		{
			// PrintWarning("Missing BaseSkillAttack");
			BaseSkillAttack = 0;
		}
		BaseSkillAttack += InteractSystem.GetValue(AttackAttrSet::Attack);
		if (!AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_SkillAttackModifier, SkillAttackModifier))
		{
			// PrintWarning("Missing SkillAttackModifier");
			SkillAttackModifier = 0;
		}
		SkillAttackModifier += InteractSystem.GetValue(SkillAttrSet::SkillAttackModifier);
		return BaseSkillAttack * SkillAttackModifier;
	}
};