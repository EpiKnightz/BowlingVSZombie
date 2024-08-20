class UTriggerOnTimeLoop : UTrigger
{
	FActorDelegate DPeriodicActivation;
	float TriggerCooldown;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{

		auto DmgRespComp = UDamageResponseComponent::Get(Ability.AbilitySystem.GetOwner());
		if (IsValid(DmgRespComp))
		{
			DPeriodicActivation.BindUFunction(Ability, n"ActivateAbility");
			DmgRespComp.EOnEnterTheBattlefield.AddUFunction(this, n"OnEnterTheBattlefield");
			TriggerCooldown = TriggerParam;
			return true;
		}
		return false;
	}

	UFUNCTION()
	void OnEnterTheBattlefield()
	{
		// Activate one time, then set timer for subsequent activation
		PeriodicActivation();
		System::SetTimer(this, n"PeriodicActivation", TriggerCooldown, true);
	}

	UFUNCTION()
	void PeriodicActivation()
	{
		DPeriodicActivation.ExecuteIfBound(nullptr);
	}
};