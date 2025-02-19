class UAttackAbility : UAbility
{
	UAttackResponseComponent AttackResponsePtr;

	protected bool GetAttackRespComp()
	{
		AttackResponsePtr = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		return IsValid(AttackResponsePtr);
	}

	UFUNCTION()
	private void OnAnimEndNotify()
	{
		AttackResponsePtr.EOnAnimHitNotify.UnbindObject(this);
		AttackResponsePtr.EOnAnimEndNotify.UnbindObject(this);
	}
}