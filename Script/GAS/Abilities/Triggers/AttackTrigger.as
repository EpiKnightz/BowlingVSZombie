class UAttackTrigger : UTrigger
{
	UAttackResponseComponent AttackResponsePtr;

	protected bool GetAttackRespComp(UAbility Ability)
	{
		AttackResponsePtr = UAttackResponseComponent::Get(Ability.InteractSystem.GetOwner());
		return IsValid(AttackResponsePtr);
	}
};