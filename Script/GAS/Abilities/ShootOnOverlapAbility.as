class UShootOnOverlapAbility : UAbility
{
	bool SetupAbilityChild() override
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse))
		{
			GetAbilityData(GameplayTags::Ability_ShootOnOverlap);
			if (AbilityData.AbilityID.IsValid())
			{
				AttackResponse.EOnBeginOverlapEvent.AddUFunction(this, n"TriggerOnOverlap");
				AttackResponse.EOnAnimHitNotify.AddUFunction(this, n"OnAnimHitNotify");
				return true;
			}
		}
		return false;
	}

	UFUNCTION()
	void TriggerOnOverlap(AActor OtherActor)
	{
		auto TargetResponse = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(TargetResponse))
		{
			if (TargetResponse.TargetType == ETargetType::Bowling)
			{
				auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
				if (IsValid(AttackResponse))
				{
					AttackResponse.DPlayAttackAnim.ExecuteIfBound();
				}
			}
		}
	}

	UFUNCTION()
	void OnAnimHitNotify()
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse) && AttackResponse.DGetAttackLocation.IsBound() && AttackResponse.DGetAttackRotation.IsBound())
		{
			SpawnActor(AbilityData.ActorTemplate, AttackResponse.DGetAttackLocation.Execute(), AttackResponse.DGetAttackRotation.Execute());
		}
	}

	void StopAbility() override
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse))
		{
			AttackResponse.EOnBeginOverlapEvent.UnbindObject(this);
			AttackResponse.EOnAnimHitNotify.UnbindObject(this);
		}
	}
};