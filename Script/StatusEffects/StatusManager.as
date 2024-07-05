class AStatusManager : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(BlueprintReadWrite)
	UDataTable NegativeEffectDT;

	TMap<FGameplayTag, FStatusDT> NegativeEffectMap;

	UPROPERTY(BlueprintReadWrite)
	UDataTable PositiveEffectDT;

	TMap<FGameplayTag, FStatusDT> PositiveEffectMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FStatusDT> NegativeEffectArray;
		NegativeEffectDT.GetAllRows(NegativeEffectArray);
		for (FStatusDT Status : NegativeEffectArray)
		{
			NegativeEffectMap.Add(Status.EffectTag, Status);
		}

		TArray<FStatusDT> PositiveEffectArray;
		PositiveEffectDT.GetAllRows(PositiveEffectArray);
		for (FStatusDT Status : PositiveEffectArray)
		{
			PositiveEffectMap.Add(Status.EffectTag, Status);
		}
	}

	UFUNCTION()
	bool ApplyStatusEffects(FGameplayTagContainer EffectTags, AActor Target)
	{

		auto DamageResponseComponent = UDamageResponseComponent::Get(Target);

		if (IsValid(DamageResponseComponent) && !DamageResponseComponent.bIsDead && !EffectTags.IsEmpty())
		{
			int errorCount = 0;
			for (FGameplayTag SingleEffect : EffectTags.GameplayTags)
			{
				if (!ApplySingleEffect(SingleEffect, Target, DamageResponseComponent))
				{
					PrintError("Can't find effect with tag: " + SingleEffect.ToString());
					errorCount++;
				}
			}
			if (errorCount == 0)
			{
				return true;
			}
		}
		return false;
	}

	UFUNCTION()
	bool ApplySingleEffect(FGameplayTag EffectTag, AActor Target, UDamageResponseComponent DRC)
	{
		UStatusComponent statusComp;
		FStatusDT EffectData;

		if (EffectTag.MatchesTag(GameplayTags::Status_Negative))
		{
			if (NegativeEffectMap.Find(EffectTag, EffectData))
			{
				if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Burn))
				{
					statusComp = UBurningComponent::GetOrCreate(Target, EffectTag.TagName);
				}
				else if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Chill))
				{
					statusComp = UChillingComponent::GetOrCreate(Target, EffectTag.TagName);
				}
				else if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Freeze))
				{
					statusComp = UFreezeComponent::GetOrCreate(Target, EffectTag.TagName);
				}
				else if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Rupture))
				{
					statusComp = URuptureComponent::GetOrCreate(Target, EffectTag.TagName);
				}
				else
				{
					return false;
				}
			}
		}
		else if (EffectTag.MatchesTag(GameplayTags::Status_Positive))
		{
			if (PositiveEffectMap.Find(EffectTag, EffectData))
			{
				if (EffectTag.MatchesTagExact(GameplayTags::Status_Positive_CooldownBoost))
				{
					statusComp = UCooldownComponent::GetOrCreate(Target, EffectTag.TagName);
				}
				else if (EffectTag.MatchesTagExact(GameplayTags::Status_Positive_AttackBoost))
				{
					statusComp = UAttackBoostComponent::GetOrCreate(Target, EffectTag.TagName);
				}
				else
				{
					return false;
				}
			}
		}
		if (IsValid(statusComp))
		{
			statusComp.Init(EffectData);
			DRC.EOnDeadCue.AddUFunction(statusComp, n"EndStatusEffect");
			return true;
		}
		return false;
	}
};