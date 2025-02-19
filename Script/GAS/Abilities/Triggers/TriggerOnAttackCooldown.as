class UTriggerOnAttackCooldown : UTrigger
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
			TriggerCooldown = Ability.AbilitySystem.GetValue(n"AttackCooldown");
			Ability.AbilitySystem.EOnPostCalculation.AddUFunction(this, n"OnCooldownUpdate");
			return true;
		}
		return false;
	}

	UFUNCTION()
	void OnEnterTheBattlefield()
	{
		// Activate one time, then set timer for subsequent activation
		PeriodicActivation();
	}

	UFUNCTION(BlueprintEvent)
	void OnCooldownUpdate(FName AttrName, float Value)
	{
		if (AttrName == n"AttackCooldown")
		{
			TriggerCooldown = Value;
			System::ClearTimer(this, "PeriodicActivation");
			PeriodicActivation();
		}
	}

	UFUNCTION(BlueprintEvent)
	void PeriodicActivation()
	{
		DPeriodicActivation.ExecuteIfBound(nullptr);
		System::SetTimer(this, n"PeriodicActivation", TriggerCooldown, false);
	}

	void StopTrigger() override
	{
		System::ClearTimer(this, "PeriodicActivation");
	}
};