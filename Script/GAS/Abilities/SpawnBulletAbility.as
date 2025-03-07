class USpawnBulletAbility : UAbility
{
	UPROPERTY(Category = Attributes, EditAnywhere)
	FVector OffsetLocation;

	float RepeatParam, DelayParam = 0;
	int RepeatCount = 0;

	void ActivateAbilityChild(AActor OtherActor) override
	{
		if (AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Repeat, RepeatParam)
			&& AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Delay, DelayParam))
		{
			RepeatCount = 0;
			RepeatSpawn();
		}
		else
		{
			SpawnBullet(AbilitySystem.GetOwner().GetActorLocation(), AbilitySystem.GetOwner().GetActorRotation());
			OnAbilityEnd();
		}
	}

	UFUNCTION()
	void RepeatSpawn()
	{
		SpawnBullet(AbilitySystem.GetOwner().GetActorLocation(), AbilitySystem.GetOwner().GetActorRotation());
		RepeatCount++;
		if (RepeatCount >= RepeatParam)
		{
			OnAbilityEnd();
			return;
		}
		System::SetTimer(this, n"RepeatSpawn", DelayParam, false);
	}

	AActor SpawnBullet(FVector Location, FRotator Rotation)
	{
		auto Actor = SpawnActor(AbilityData.ActorTemplate, CalculateOffset(Location, Rotation), Rotation);
		if (IsValid(Actor))
		{
			auto ProjDataComp = UProjectileDataComponent::Get(Actor);
			ProjDataComp.ProjectileData = AbilityData;
			ProjDataComp.AddEffects(AbilitySystem.GetCurrentActorTags().Filter(GameplayTags::Ability.GetSingleTagContainer()));
			ProjDataComp.AddEffects(AbilitySystem.GetCurrentActorTags().Filter(GameplayTags::Status_Negative.GetSingleTagContainer()));

			float BaseSkillAttack, SkillAttackModifier = 0;
			if (!AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_BaseSkillAttack, BaseSkillAttack))
			{
				// PrintWarning("Missing BaseSkillAttack");
				BaseSkillAttack = 0;
			}
			BaseSkillAttack += AbilitySystem.GetValue(AttackAttrSet::Attack);
			if (!AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_SkillAttackModifier, SkillAttackModifier))
			{
				// PrintWarning("Missing SkillAttackModifier");
				SkillAttackModifier = 0;
			}
			SkillAttackModifier += AbilitySystem.GetValue(SkillAttrSet::SkillAttackModifier);
			ProjDataComp.ProjectileData.Atk = float32(BaseSkillAttack * SkillAttackModifier);
		}
		return Actor;
	}

	FVector CalculateOffset(FVector Location, FRotator Rotation)
	{
		return Location + OffsetLocation.RotateAngleAxis(Rotation.ZYaw - 180, FVector(0, 0, 1));
	}

	void OnAbilityEnd() override
	{
		System::ClearTimer(this, "RepeatSpawn");
		Super::OnAbilityEnd();
	}
};