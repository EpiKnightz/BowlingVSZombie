class UTriggerOnOverlap : UAttackTrigger
{
	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		if (GetAttackRespComp(Ability))
		{
			AttackResponsePtr.EOnBeginOverlapEvent.AddUFunction(Ability, n"ActivateAbility");
			return true;
		}
		return false;
	}

	bool CanActivate(AActor OtherActor) override
	{
		auto TargetResponse = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(TargetResponse) && TargetResponse.TargetType == ETargetType::Bowling)
		{
			return true;
		}
		return false;
	}

	void StopTrigger() override
	{
		if (IsValid(AttackResponsePtr))
		{
			AttackResponsePtr.EOnBeginOverlapEvent.UnbindObject(this.GetOuter());
		}
	}
};