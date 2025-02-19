class USlashAreaAbility : UAttackAbility
{
	bool SetupAbilityChild() override
	{
		if (GetAttackRespComp() && AbilityData.AbilityID.IsValid())
		{
			return true;
		}
		return false;
	}

	void ActivateAbilityChild(AActor OtherActor) override
	{
		if (IsValid(AttackResponsePtr))
		{
			AttackResponsePtr.EOnAnimHitNotify.AddUFunction(this, n"OnAnimHitNotify");
			AttackResponsePtr.EOnAnimEndNotify.AddUFunction(this, n"OnAnimEndNotify");
			AttackResponsePtr.DPlayAttackAnim.ExecuteIfBound();
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
					// Todo: Remove hardcoded damage
					DamageResponse.DOnTakeHit.ExecuteIfBound(100);
				}
			}
		}
	}
}