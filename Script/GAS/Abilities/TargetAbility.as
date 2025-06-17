enum ESearchType
{
	Closest,
	Farthest,
	Random,
	None
};

class UTargetAbility : USkillAbility
{
	UPROPERTY()
	UNiagaraSystem HitVFX;

	UPROPERTY()
	EObjectTypeQuery TargetType;

	UPROPERTY()
	ESearchType SearchType = ESearchType::Closest;

	USceneComponent RootTransform;
	float Range = 200;

	bool SetupAbilityChild() override
	{
		RootTransform = (InteractSystem.GetOwner().GetRootComponent());
		if (IsValid(RootTransform))
		{
			return true;
		}
		PrintError("Target Ability setup failed");
		return false;
	}

	void ActivateAbilityChild(AActor OtherActor) override
	{
		if (AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Range, Range))
		{
			AActor Target = SearchForTarget(Range);
			if (IsValid(Target))
			{
				ActivateTargetAbility(Target);
			}
		}
	}

	UFUNCTION()
	void ActivateTargetAbility(AActor Target)
	{}

	AActor SearchForTarget(float MaxRange)
	{
		TArray<EObjectTypeQuery> traceObjectTypes;
		traceObjectTypes.Add(TargetType);
		TArray<AActor> ignoreActors;
		TArray<AActor> outActors;
		System::SphereOverlapActors(InteractSystem.GetOwner().GetActorLocation(), MaxRange, traceObjectTypes, nullptr, ignoreActors, outActors);

		switch (SearchType)
		{
			case ESearchType::Closest:
			{
				float32 Distance = 9999;

				return Gameplay::FindNearestActor(RootTransform.GetWorldLocation(), outActors, Distance);
			}
			case ESearchType::Farthest:
			{
				float32 Distance = 0;

				return Gameplay::FindFarthestActor(RootTransform.GetWorldLocation(), outActors, Distance);
			}
			case ESearchType::Random:
			{
				if (outActors.Num() > 0)
				{
					return outActors[Math::RandRange(0, outActors.Num() - 1)];
				}
				break;
			}
			default:
				return nullptr;
		}
		return nullptr;
	}
}