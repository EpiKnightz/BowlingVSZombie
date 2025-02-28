class USpawnBulletSkill : UAttackAbility
{
	UPROPERTY(Category = Attributes, EditAnywhere)
	FVector OffsetLocation;

	void ActivateAbilityChild(AActor OtherActor) override
	{
		SpawnBullet(AbilitySystem.GetOwner().GetActorLocation(), AbilitySystem.GetOwner().GetActorRotation());
		OnAbilityEnd();
	}

	void SpawnBullet(FVector Location, FRotator Rotation)
	{
		auto Actor = SpawnActor(AbilityData.ActorTemplate, Location + OffsetLocation.RotateAngleAxis(Rotation.ZYaw - 180, FVector(0, 0, 1)), Rotation);
		if (IsValid(Actor))
		{
			auto ProjDataComp = UProjectileDataComponent::Get(Actor);
			ProjDataComp.ProjectileData = AbilityData;
			ProjDataComp.AddEffects(AbilitySystem.GetCurrentActorTags());
			ProjDataComp.ProjectileData.Atk = AbilitySystem.GetValue(AttackAttrSet::Attack) * AbilitySystem.GetValue(SkillAttrSet::SkillAttackModifier);
		}
	}
};