class URangeAttackComponent : UResponseComponent
{
	UPROPERTY(BlueprintReadWrite, meta = (EditCondition = "AttackRange > 100", EditConditionHides), Category = Projectile)
	TSubclassOf<AActor> ProjectileTemplate;

	void SpawnBullet(FVector Loc, FRotator Rot, USceneComponent Target = nullptr)
	{
		auto Actor = SpawnActor(ProjectileTemplate, Loc, Rot);
		if (IsValid(Actor))
		{
			auto ProjDataComp = UProjectileDataComponent::Get(Actor);
			if (IsValid(ProjDataComp))
			{
				ProjDataComp.SetAttack(InteractSystem.GetValue(AttackAttrSet::Attack));
			}
			if (IsValid(Target))
			{
				auto MovementComp = UProjectileMovementComponent::Get(Actor);
				if (IsValid(MovementComp))
				{
					MovementComp.bIsHomingProjectile = true;
					MovementComp.SetHomingTargetComponent(Target);
					MovementComp.HomingAccelerationMagnitude = 1000;
				}
			}
		}
	}

	void SetProjectileTemplate(TSubclassOf<AActor> iProjectileTemplate)
	{
		if (IsValid(iProjectileTemplate))
		{
			ProjectileTemplate = iProjectileTemplate;
		}
	}
};