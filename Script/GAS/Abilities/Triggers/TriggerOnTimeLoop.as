class UTriggerOnTimeLoop : UTriggerOnAttackCooldown
{
	float TriggerCooldownModifier = 1;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{

		auto DmgRespComp = UDamageResponseComponent::Get(Ability.InteractSystem.GetOwner());
		if (IsValid(DmgRespComp))
		{
			DPeriodicActivation.BindUFunction(Ability, n"ActivateAbility");
			DmgRespComp.EOnEnterTheBattlefield.AddUFunction(this, n"OnFirstActivation");
			DmgRespComp.EOnNewCardAdded.AddUFunction(this, n"OnFirstActivation");
			TriggerCooldown = TriggerParam;
			Ability.InteractSystem.EOnPostCalculation.AddUFunction(this, n"OnCooldownUpdate");
			return true;
		}
		return false;
	}

	void OnCooldownUpdate(FName AttrName, float Value) override
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

	void PeriodicActivation() override
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