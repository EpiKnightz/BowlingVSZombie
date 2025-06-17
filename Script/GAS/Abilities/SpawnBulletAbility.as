class USpawnBulletAbility : USkillAbility
{
	UPROPERTY(Category = Attributes, EditAnywhere)
	FVector OffsetLocation;

	float RepeatParam, DelayParam = 0;
	int RepeatCount = 0;
	float SkillAttack = 0;

	void ActivateAbilityChild(AActor OtherActor) override
	{
		if (AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Repeat, RepeatParam)
			&& AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Delay, DelayParam))
		{
			RepeatCount = 0;
			SkillAttack = CalculateSkillAttack();
			RepeatSpawn();
		}
		else
		{
			SpawnBullet(InteractSystem.GetOwner().GetActorLocation(), InteractSystem.GetOwner().GetActorRotation());
			OnAbilityEnd();
		}
	}

	UFUNCTION()
	void RepeatSpawn()
	{
		SpawnBullet(InteractSystem.GetOwner().GetActorLocation(), InteractSystem.GetOwner().GetActorRotation());
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
			ProjDataComp.SetAbilityData(AbilityData);
			// ProjDataComp.AddEffects(InteractSystem.GetCurrentActorTags().Filter(GameplayTags::Ability.GetSingleTagContainer()));
			ProjDataComp.AddEffects(InteractSystem.GetCurrentActorTags().Filter(GameplayTags::Status_Negative.GetSingleTagContainer()));
			ProjDataComp.SetAttack(float32(SkillAttack));

			auto HostTargetResponse = UTargetResponseComponent::Get(InteractSystem.GetOwner());
			if (IsValid(HostTargetResponse))
			{
				auto BulletTargetResponse = UTargetResponseComponent::Get(Actor);
				if (IsValid(BulletTargetResponse))
				{
					BulletTargetResponse.GetInfoFromHost(HostTargetResponse, AbilityData.AbilityID);
				}
			}
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