class UAttackAbility : UAbility
{
	UAttackResponseComponent AttackResponsePtr;

	protected bool GetAttackRespComp()
	{
		AttackResponsePtr = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		return IsValid(AttackResponsePtr);
	}
}