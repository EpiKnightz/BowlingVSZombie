class UTrigger
{
	bool SetupTrigger(UAbility Ability, float TriggerParam = 0)
	{
		return false;
	}

	bool CanActivate(AActor Target)
	{
		return true;
	}

	void StopTrigger()
	{}
};