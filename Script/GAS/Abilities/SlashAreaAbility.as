class USlashAreaAbility : UAttackAbility
{
	void ActivateAbilityChild(AActor OtherActor) override
	{
		if (IsValid(AttackResponsePtr))
		{
			AttackResponsePtr.EOnAnimHitNotify.AddUFunction(this, n"OnAnimHitNotify");
			AttackResponsePtr.EOnAnimEndNotify.AddUFunction(this, n"OnAnimEndNotify");
			AttackResponsePtr.ActivateAttack();
		}
	}

	UFUNCTION()
	private void OnAnimHitNotify()
	{
		if (IsValid(AttackResponsePtr) && AttackResponsePtr.DGetAttackLocation.IsBound())
		{
			TArray<EObjectTypeQuery> traceObjectTypes;
			traceObjectTypes.Add(EObjectTypeQuery::Enemy);
			TArray<AActor> ignoreActors;
			TArray<AActor> outActors;
			// InteractSystem.SetBaseValue(AttackAttrSet::AttackRange, 165);
			float radius = InteractSystem.GetValue(AttackAttrSet::AttackRange);
			// Print("SlashAreaAbility: OnAnimHitNotify" + radius);
			System::SphereOverlapActors(AttackResponsePtr.DGetAttackLocation.Execute(), InteractSystem.GetValue(AttackAttrSet::AttackRange), traceObjectTypes, nullptr, ignoreActors, outActors);

			for (AActor overlappedActor : outActors)
			{
				UDamageResponseComponent DamageResponse = UDamageResponseComponent::Get(overlappedActor);
				if (IsValid(DamageResponse))
				{
					DamageResponse.DOnTakeHit.ExecuteIfBound(InteractSystem.GetValue(AttackAttrSet::Attack));
					auto StatusResponse = UStatusResponseComponent::Get(overlappedActor);
					if (IsValid(StatusResponse))
					{
						StatusResponse.DOnApplyStatus.ExecuteIfBound(InteractSystem.GetCurrentActorTags().Filter(GameplayTags::Status_Negative.GetSingleTagContainer()));
					}
				}
			}
		}
	}
}