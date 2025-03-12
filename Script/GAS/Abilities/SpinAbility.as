class USpinAbility : USkillAbility
{
	float Interval = 0.1;
	float Duration = 10;
	float Range = 200;
	protected UFCTweenBPActionFloat FloatTween;
	USceneComponent RootTransform;

	bool SetupAbilityChild() override
	{
		RootTransform = (AbilitySystem.GetOwner().GetRootComponent());
		if (IsValid(RootTransform))
		{
			return true;
		}
		PrintError("Spin setup failed");
		return false;
	}

	void ActivateAbilityChild(AActor OtherActor) override
	{
		if (AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Interval, Interval)
			&& AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Duration, Duration)
			&& AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Range, Range))
		{
			DamageInterval();
			System::SetTimer(this, n"OnAbilityEnd", Duration, false);
			if (IsValid(FloatTween) && FloatTween.IsValid())
			{
				FloatTween.Stop();
				FloatTween.ApplyEasing.Clear();
			}
			FloatTween = UFCTweenBPActionFloat::TweenFloat(0, 360, Interval, EFCEase::Linear, 0, 0, 0, -1);
			FloatTween.ApplyEasing.AddUFunction(this, n"SetRotation");
			FloatTween.Start();
		}
	}

	UFUNCTION()
	void SetRotation(float32 Rotation)
	{
		RootTransform.SetWorldRotation(FRotator(0, Rotation, 0));
	}

	UFUNCTION()
	private void ResetRotation()
	{
		SetRotation(0);
	}

	UFUNCTION()
	void DamageInterval()
	{
		SpinToWin();
		System::SetTimer(this, n"DamageInterval", Interval, false);
	}

	UFUNCTION()
	private void SpinToWin()
	{
		TArray<EObjectTypeQuery> traceObjectTypes;
		traceObjectTypes.Add(EObjectTypeQuery::Enemy);
		TArray<AActor> ignoreActors;
		TArray<AActor> outActors;
		System::SphereOverlapActors(AbilitySystem.GetOwner().GetActorLocation(), Range, traceObjectTypes, nullptr, ignoreActors, outActors);

		for (AActor overlappedActor : outActors)
		{
			UDamageResponseComponent DamageResponse = UDamageResponseComponent::Get(overlappedActor);
			if (IsValid(DamageResponse))
			{
				DamageResponse.DOnTakeHit.ExecuteIfBound(CalculateSkillAttack(), GameplayTags::Description_Element_Aether);
				auto StatusResponse = UStatusResponseComponent::Get(overlappedActor);
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(AbilitySystem.GetCurrentActorTags().Filter(GameplayTags::Status_Negative.GetSingleTagContainer()));
				}
			}
		}
	}

	void OnAbilityEnd() override
	{
		System::ClearTimer(this, "DamageInterval");
		FloatTween.Stop();
		FloatTween.ApplyEasing.Clear();
		ResetRotation();
		Super::OnAbilityEnd();
	}
}