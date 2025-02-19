class UTriggerOnRageFull : URageTrigger
{
	FActorDelegate DActivateAbility;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		if (GetRageRespComp(Ability))
		{
			DActivateAbility.BindUFunction(Ability, n"ActivateAbility");
			RageResponsePtr.EOnRageFull.AddUFunction(this, n"OnRageFull");
			return true;
		}
		return false;
	}

	UFUNCTION()
	void OnRageFull()
	{
		DActivateAbility.ExecuteIfBound(nullptr);
	}

	void StopTrigger() override
	{
		RageResponsePtr.EOnRageFull.UnbindObject(this);
	}
}