class UTriggerOnAttackCooldown : UTrigger
{
	FActorDelegate DPeriodicActivation;
	float TriggerCooldown;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		auto DmgRespComp = UDamageResponseComponent::Get(Ability.InteractSystem.GetOwner());
		if (IsValid(DmgRespComp))
		{
			DPeriodicActivation.BindUFunction(Ability, n"ActivateAbility");
			DmgRespComp.EOnEnterTheBattlefield.AddUFunction(this, n"OnFirstActivation");
			DmgRespComp.EOnNewCardAdded.AddUFunction(this, n"OnFirstActivation");
			TriggerCooldown = Ability.InteractSystem.GetValue(AttackAttrSet::AttackCooldown);
			Ability.InteractSystem.EOnPostCalculation.AddUFunction(this, n"OnCooldownUpdate");
			return true;
		}
		return false;
	}

	UFUNCTION()
	void OnFirstActivation()
	{
		// Activate one time, then set timer for subsequent activation
		PeriodicActivation();
	}

	UFUNCTION()
	void OnCooldownUpdate(FName AttrName, float Value)
	{
		if (AttrName == AttackAttrSet::AttackCooldown)
		{
			TriggerCooldown = Value;
			System::ClearTimer(this, "PeriodicActivation");
			PeriodicActivation();
		}
	}

	UFUNCTION()
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