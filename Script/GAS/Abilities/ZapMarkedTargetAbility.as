class UZapMarkedTargetAbility : USkillAbility
{
	TArray<FFloat2BoolDelegate> TakeHitArray;

	bool SetupAbilityChild() override
	{
		auto StatusMan = Gameplay::GetActorOfClass(AStatusManager);
		if (IsValid(StatusMan))
		{
			StatusMan.EOnStatusApplied.AddUFunction(this, n"OnStatusApplied");
			return true;
		}
		PrintError("ZapMarkedTarget setup failed");
		return false;
	}

	void ActivateAbilityChild(AActor OtherActor) override
	{
		if (TakeHitArray.Num() > 0)
		{
			for (FFloat2BoolDelegate Delegate : TakeHitArray)
			{
				Delegate.ExecuteIfBound(CalculateSkillAttack());
			}
		}
	}

	UFUNCTION()
	private void OnStatusApplied(FGameplayTag Tag, UStatusComponent Target)
	{
		if (Tag == GameplayTags::Status_Negative_Mark_Thunder)
		{
			UDamageResponseComponent DamageResponse = UDamageResponseComponent::Get(Target.GetOwner());
			if (IsValid(DamageResponse))
			{
				TakeHitArray.AddUnique(DamageResponse.DOnTakeHit);
			}
		}
	}
};