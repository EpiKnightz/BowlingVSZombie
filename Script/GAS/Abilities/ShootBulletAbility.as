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
			SpawnBullet(AttackResponsePtr.DGetAttackLocation.Execute(), AttackResponsePtr.DGetAttackRotation.Execute());
		}
	}

	void SpawnBullet(FVector Location, FRotator Rotation)
	{
		auto Actor = SpawnActor(AbilityData.ActorTemplate, Location, Rotation);
		if (IsValid(Actor))
		{
			auto ProjDataComp = UProjectileDataComponent::Get(Actor);
			ProjDataComp.ProjectileData = AbilityData;
			ProjDataComp.AddEffects(AbilitySystem.GetCurrentActorTags().Filter(GameplayTags::Ability.GetSingleTagContainer()));
			ProjDataComp.ProjectileData.Atk = AbilitySystem.GetValue(AttackAttrSet::Attack);
		}
	}
};