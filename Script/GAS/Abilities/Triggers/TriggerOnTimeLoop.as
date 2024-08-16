class UTriggerOnTimeLoop : UTrigger
{
	FActorDelegate DOnPeriodicActivation;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		DOnPeriodicActivation.BindUFunction(Ability, n"ActivateAbility");
		System::SetTimer(this, n"PeriodicActivation", TriggerParam, true);
		return true;
	}

	UFUNCTION()
	void PeriodicActivation()
	{
		DOnPeriodicActivation.ExecuteIfBound(nullptr);
	}
};