class USpawnBulletSkill : UAbility
{
	UPROPERTY(Category = Attributes, EditAnywhere)
	FVector OffsetLocation;

	void ActivateAbilityChild(AActor OtherActor) override
	{
		SpawnBullet(AbilitySystem.GetOwner().GetActorLocation(), AbilitySystem.GetOwner().GetActorRotation());
	}

	void SpawnBullet(FVector Location, FRotator Rotation)
	{
		auto Actor = SpawnActor(AbilityData.ActorTemplate, Location + OffsetLocation.RotateAngleAxis(Rotation.ZYaw - 180, FVector(0, 0, 1)), Rotation);
		if (IsValid(Actor))
		{
			auto ProjDataComp = UProjectileDataComponent::Get(Actor);
			ProjDataComp.ProjectileData = AbilityData;
			ProjDataComp.ProjectileData.Atk = AbilitySystem.GetValue(AttackAttrSet::Attack);
		}
	}
};