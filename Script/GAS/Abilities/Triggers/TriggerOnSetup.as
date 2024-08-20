// Not actually at setup, we need to trigger when the drag is released and survivor active in the field
class UTriggerOnSetup : UTrigger
{
	FActorDelegate DActivateAbility;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		DActivateAbility.BindUFunction(Ability, n"ActivateAbility");
		auto DmgRespComp = UDamageResponseComponent::Get(Ability.AbilitySystem.GetOwner());
		if (IsValid(DmgRespComp))
		{
			DmgRespComp.EOnEnterTheBattlefield.AddUFunction(this, n"OnEnterTheBattlefield");
		}
		return true;
	}

	UFUNCTION()
	void OnEnterTheBattlefield()
	{
		DActivateAbility.ExecuteIfBound(nullptr);
	}
};