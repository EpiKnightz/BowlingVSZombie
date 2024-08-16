class UTriggerOnOverlapMarkTarget : UAttackTrigger
{
	private UAbility AbilityPtr;

	bool SetupTrigger(UAbility Ability, float TriggerParam) override
	{
		if (GetAttackRespComp(Ability))
		{
			auto Collider = UCapsuleComponent::Get(Ability.AbilitySystem.GetOwner());
			if (IsValid(Collider))
			{
				Collider.SetCollisionResponseToChannel(ECollisionChannel::Bowling, ECollisionResponse::ECR_Overlap);
			}

			AbilityPtr = Ability;
			AttackResponsePtr.EOnBeginOverlapEvent.AddUFunction(this, n"MarkTarget");
			return true;
		}
		return false;
	}

	UFUNCTION()
	void MarkTarget(AActor OtherActor)
	{
		ABowling Bowling = Cast<ABowling>(OtherActor);
		if (IsValid(Bowling))
		{
			Bowling.EOnHit.AddUFunction(AbilityPtr, n"ActivateAbility");
		}
	}

	bool CanActivate(AActor Target) override
	{
		auto TargetResponse = UTargetResponseComponent::Get(Target);
		if (IsValid(TargetResponse))
		{
			if (TargetResponse.TargetType == ETargetType::Zombie)
			{
				return true;
			}
		}
		return false;
	}

	void StopTrigger() override
	{
		AttackResponsePtr.EOnBeginOverlapEvent.UnbindObject(this);
	}
};