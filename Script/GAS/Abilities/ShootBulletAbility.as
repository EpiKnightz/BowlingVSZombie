class UShootBulletAbility : UAttackAbility
{
	bool SetupAbilityChild() override
	{
		if (GetAttackRespComp())
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
			ProjDataComp.ProjectileData.Atk = AbilitySystem.GetValue(AttackAttrSet::Attack);
		}
	}

	void StopAbility() override
	{
		if (IsValid(AttackResponsePtr))
		{
			AttackResponsePtr.EOnAnimHitNotify.UnbindObject(this);
		}
	}
};