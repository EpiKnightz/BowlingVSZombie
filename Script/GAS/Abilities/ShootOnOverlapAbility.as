class UShootOnOverlapAbility : UAbility
{
	bool SetupAbilityChild() override
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse))
		{
			AbilityID = FGameplayTag::RequestGameplayTag(n"Ability.ShootOnOverlap");
			GetAbilityData();
			if (AbilityData.AbilityID.IsValid())
			{
				AttackResponse.EOnOverlapEvent.AddUFunction(this, n"TriggerOnOverlap");
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
	private void OnAnimHitNotify()
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse) && AttackResponse.DGetAttackLocation.IsBound() && AttackResponse.DGetAttackRotation.IsBound())
		{
			SpawnActor(AbilityData.ActorTemplate, AttackResponse.DGetAttackLocation.Execute(), AttackResponse.DGetAttackRotation.Execute());
		}
	}
};