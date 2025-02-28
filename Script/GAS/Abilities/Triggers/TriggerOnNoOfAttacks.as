class UTriggerOnNoOfAttacks : UAttackTrigger
{
	int NoOfAttacks = 3;

	FActorDelegate DActivateAbility;
	FVoidDelegate DEndAbility;
	private int CurrentAtkTimes = 0;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		if (GetAttackRespComp(Ability))
		{
			NoOfAttacks = int(TriggerParam);
			DActivateAbility.BindUFunction(Ability, n"ActivateAbility");
			DEndAbility.BindUFunction(Ability, n"OnAbilityEnd");
			AttackResponsePtr.EOnPreAttackActivate.AddUFunction(this, n"OnPreAttackActivate");
			AttackResponsePtr.EOnAnimEndNotify.AddUFunction(this, n"OnEndAttack");
			return true;
		}
		return false;
	}

	UFUNCTION()
	private void OnPreAttackActivate()
	{
		CurrentAtkTimes++;
		if (CurrentAtkTimes >= NoOfAttacks)
		{
			CurrentAtkTimes = 0;
			DActivateAbility.ExecuteIfBound(nullptr);
		}
	}

	UFUNCTION()
	private void OnEndAttack()
	{
		DEndAbility.ExecuteIfBound();
	}

	void StopTrigger() override
	{
		AttackResponsePtr.EOnPreAttackActivate.UnbindObject(this);
		CurrentAtkTimes = 0;
	}
};