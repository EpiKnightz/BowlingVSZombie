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
			System::SphereOverlapActors(AttackResponsePtr.DGetAttackLocation.Execute(), 165, traceObjectTypes, nullptr, ignoreActors, outActors);

			for (AActor overlappedActor : outActors)
			{
				UDamageResponseComponent DamageResponse = UDamageResponseComponent::Get(overlappedActor);
				if (IsValid(DamageResponse))
				{
					DamageResponse.DOnTakeHit.ExecuteIfBound(AbilitySystem.GetValue(AttackAttrSet::Attack));
				}
			}
		}
	}
}