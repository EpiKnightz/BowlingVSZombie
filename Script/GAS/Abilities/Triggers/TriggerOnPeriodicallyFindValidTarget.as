class UTriggerOnPeriodicallyFindValidTarget : UTrigger
{
	FActorDelegate DPeriodicActivation;
	AActor AbilityOwner;
	UInteractSystem InteractSystem;
	float TriggerCooldown;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		AbilityOwner = Ability.InteractSystem.GetOwner();
		InteractSystem = Ability.InteractSystem;
		auto DmgRespComp = UDamageResponseComponent::Get(AbilityOwner);
		if (IsValid(DmgRespComp))
		{
			DPeriodicActivation.BindUFunction(Ability, n"ActivateAbility");
			DmgRespComp.EOnEnterTheBattlefield.AddUFunction(this, n"OnFirstActivation");
			DmgRespComp.EOnNewCardAdded.AddUFunction(this, n"OnFirstActivation");
			TriggerCooldown = TriggerParam;
			return true;
		}
		return false;
	}

	UFUNCTION()
	void OnFirstActivation()
	{
		// Activate one time, then set timer for subsequent activation
		PeriodicActivation();
		System::SetTimer(this, n"PeriodicActivation", TriggerCooldown, true);
		// Note: This mean the trigger cooldown won't be affected by the cooldown modifier
	}

	UFUNCTION()
	void PeriodicActivation()
	{
		TArray<AActor> OverlappingActors;
		if (FindNearestTarget(OverlappingActors, EObjectTypeQuery::Enemy))
		{
			DPeriodicActivation.ExecuteIfBound(OverlappingActors[0]);
		}
	}

	bool FindNearestTarget(TArray<AActor>& OverlappingActors, EObjectTypeQuery iTargetType)
	{
		TArray<EObjectTypeQuery> traceObjectTypes;
		traceObjectTypes.Add(iTargetType);
		TArray<AActor> ignoreActors;
		ignoreActors.Add(AbilityOwner);
		TArray<AActor> outActors;
		System::SphereOverlapActors(AbilityOwner.GetActorLocation(), InteractSystem.GetValue(AttackAttrSet::AttackRange) * 2, traceObjectTypes, nullptr, ignoreActors, outActors);

		float32 Distance = -1;
		AActor NearestTarget = Gameplay::FindNearestActor(AbilityOwner.GetActorLocation(), outActors, Distance);
		if (IsValid(NearestTarget))
		{
			OverlappingActors.Add(NearestTarget);
			return true;
		}
		return false;
	}
};