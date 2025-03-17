class UShootBulletAbility : UAttackAbility
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
	void OnAnimHitNotify()
	{
		if (IsValid(AttackResponsePtr)
			&& AttackResponsePtr.DGetAttackLocation.IsBound()
			&& AttackResponsePtr.DGetAttackRotation.IsBound())
		{
			FRotator Rotation = AttackResponsePtr.DGetAttackRotation.Execute();
			SpawnBullet(AttackResponsePtr.DGetAttackLocation.Execute(), Rotation);
			if (AttackResponsePtr.IsDualWield())
			{
				SpawnBullet(AttackResponsePtr.DGetOffhandAttackLocation.Execute(), Rotation);
			}
		}
	}

	void SpawnBullet(FVector Location, FRotator Rotation)
	{
		auto Actor = SpawnActor(AbilityData.ActorTemplate, Location, Rotation);
		if (IsValid(Actor))
		{
			auto ProjDataComp = UProjectileDataComponent::Get(Actor);
			ProjDataComp.SetAbilityData(AbilityData);
			// ProjDataComp.AddEffects(AbilitySystem.GetCurrentActorTags().Filter(GameplayTags::Ability.GetSingleTagContainer()));
			ProjDataComp.AddEffects(AbilitySystem.GetCurrentActorTags().Filter(GameplayTags::Status_Negative.GetSingleTagContainer()));
			ProjDataComp.SetAttack(AbilitySystem.GetValue(AttackAttrSet::Attack));

			auto HostTargetResponse = UTargetResponseComponent::Get(AbilitySystem.GetOwner());
			if (IsValid(HostTargetResponse))
			{
				auto BulletTargetResponse = UTargetResponseComponent::Get(Actor);
				if (IsValid(BulletTargetResponse))
				{
					BulletTargetResponse.GetInfoFromHost(HostTargetResponse, AbilityData.AbilityID);
				}
			}
		}
	}
};