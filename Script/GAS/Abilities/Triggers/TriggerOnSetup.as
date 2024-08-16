class UTriggerOnSetup : UTrigger
{
	FActorDelegate DOnPeriodicActivation;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		Ability.ActivateAbility(nullptr);
		return true;
	}
};