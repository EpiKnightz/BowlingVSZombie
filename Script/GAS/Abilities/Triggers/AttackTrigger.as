class UAttackTrigger : UTrigger
{
	UAttackResponseComponent AttackResponsePtr;

	protected bool GetAttackRespComp(UAbility Ability)
	{
		AttackResponsePtr = UAttackResponseComponent::Get(Ability.AbilitySystem.GetOwner());
		return IsValid(AttackResponsePtr);
	}
};