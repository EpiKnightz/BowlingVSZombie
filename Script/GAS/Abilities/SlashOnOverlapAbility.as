class USlashOnOverlapAbility : UAbility
{
	bool SetupAbilityChild() override
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse))
		{
			GetAbilityData(GameplayTags::Ability_SlashOnOverlap);
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
	private void OnAnimHitNotify()
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse) && AttackResponse.DGetAttackLocation.IsBound())
		{
			TArray<EObjectTypeQuery> traceObjectTypes;
			traceObjectTypes.Add(EObjectTypeQuery::Enemy);
			TArray<AActor> ignoreActors;
			TArray<AActor> outActors;
			System::SphereOverlapActors(AttackResponse.DGetAttackLocation.Execute(), 165, traceObjectTypes, nullptr, ignoreActors, outActors);

			for (AActor overlappedActor : outActors)
			{
				UDamageResponseComponent DamageResponse = UDamageResponseComponent::Get(overlappedActor);
				if (IsValid(DamageResponse))
				{
					DamageResponse.DOnTakeHit.ExecuteIfBound(100);
				}
			}
		}
	}
}