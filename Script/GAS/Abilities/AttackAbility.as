class UAttackAbility : UAbility
{
	UAttackResponseComponent AttackResponsePtr;

	bool SetupAbilityChild() override
	{
		if (GetAttackRespComp() && AbilityData.AbilityID.IsValid())
		{
			return true;
		}
		return false;
	}

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
		OnAbilityEnd();
	}
}