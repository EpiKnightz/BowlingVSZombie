class UTriggerOnTimeLoop : UTriggerOnAttackCooldown
{
	float TriggerCooldownModifier = 1;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{

		auto DmgRespComp = UDamageResponseComponent::Get(Ability.AbilitySystem.GetOwner());
		if (IsValid(DmgRespComp))
		{
			DPeriodicActivation.BindUFunction(Ability, n"ActivateAbility");
			DmgRespComp.EOnEnterTheBattlefield.AddUFunction(this, n"OnEnterTheBattlefield");
			TriggerCooldown = TriggerParam;
			Ability.AbilitySystem.EOnPostCalculation.AddUFunction(this, n"OnCooldownUpdate");
			return true;
		}
		return false;
	}

	UFUNCTION(BlueprintOverride, meta = (NoSuperCall))
	void OnCooldownUpdate(FName AttrName, float Value)
	{
		if (AttrName == SkillAttrSet::SkillCooldownModifier)
		{
			TriggerCooldownModifier = Value;
			float remainingTime = System::GetTimerRemainingTime(this, "PeriodicActivation");
			if (remainingTime > 0)
			{
				remainingTime /= TriggerCooldownModifier;
				System::ClearTimer(this, "PeriodicActivation");
				System::SetTimer(this, n"PeriodicActivation", remainingTime, false);
			}
		}
	}

	UFUNCTION(BlueprintOverride, meta = (NoSuperCall))
	void PeriodicActivation()
	{
		DPeriodicActivation.ExecuteIfBound(nullptr);
		System::SetTimer(this, n"PeriodicActivation", TriggerCooldown / TriggerCooldownModifier, false);
	}

	void StopTrigger() override
	{
		System::ClearTimer(this, "PeriodicActivation");
		Super::StopTrigger();
	}
};