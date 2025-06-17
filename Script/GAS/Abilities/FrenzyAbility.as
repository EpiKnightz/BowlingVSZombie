class UFrenzyAbility : UStatusAbility
{
	// UPROPERTY(BlueprintReadWrite)
	TArray<FGameplayTag> StatusEffectTags;

	protected UFCTweenBPActionFloat FloatTween;

	USceneComponent RootTransform;

	bool SetupAbilityChild() override
	{
		RootTransform = (InteractSystem.GetOwner().GetRootComponent());
		if (IsValid(RootTransform) && GetStatusRespComp())
		{
			return true;
		}
		PrintError("Frenzy setup failed");
		return false;
	}

	void ActivateAbilityChild(AActor Target) override
	{
		AbilityData.AbilityParams.GetKeys(StatusEffectTags);
		StatusResponsePtr.ApplyStatusEffect(GameplayTag::MakeGameplayTagContainerFromArray(StatusEffectTags));
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(-90, 90, 1, EFCEase::Linear, 0, 0, 0, int(AbilityData.TriggerParam / 2), 0, true);
		FloatTween.ApplyEasing.AddUFunction(this, n"SetRotation");
		FloatTween.OnComplete.AddUFunction(this, n"OnAbilityEnd");
		FloatTween.Start();
	}

	UFUNCTION()
	void SetRotation(float32 Rotation)
	{
		RootTransform.SetWorldRotation(FRotator(0, Rotation, 0));
	}

	void OnAbilityEnd() override
	{
		ResetRotation();
		Super::OnAbilityEnd();
	}

	UFUNCTION()
	private void ResetRotation()
	{
		SetRotation(0);
	}
}