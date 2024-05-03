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
		NegativeEffectDT.GetAllRows(PositiveEffectArray);
		for (FStatusDT Status : PositiveEffectArray)
		{
			PositiveEffectMap.Add(Status.EffectTag, Status);
		}
	}

	UFUNCTION()
	bool ApplyStatusEffects(FGameplayTagContainer EffectTags, AActor Target)
	{
		if (!EffectTags.IsEmpty())
		{
			int errorCount = 0;
			for (FGameplayTag SingleEffect : EffectTags.GameplayTags)
			{
				if (!ApplySingleEffect(SingleEffect, Target))
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
	bool ApplySingleEffect(FGameplayTag EffectTag, AActor Target)
	{
		UStatusComponent statusComp;
		FStatusDT EffectData;

		if (EffectTag.MatchesTag(GameplayTags::Status_Negative))
		{
			if (NegativeEffectMap.Find(EffectTag, EffectData))
			{
				if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Burn))
				{
					statusComp = UDoTComponent::GetOrCreate(Target, GameplayTags::Status_Negative_Burn.TagName);
				}
				else if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Chill))
				{
					statusComp = UChillingComponent::GetOrCreate(Target, GameplayTags::Status_Negative_Chill.TagName);
				}
				else if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Freeze))
				{
					statusComp = UFreezeComponent::GetOrCreate(Target, GameplayTags::Status_Negative_Freeze.TagName);
				}
				else if (EffectTag.MatchesTagExact(GameplayTags::Status_Negative_Rupture))
				{
					statusComp = URuptureComponent::GetOrCreate(Target, GameplayTags::Status_Negative_Freeze.TagName);
				}
				else
				{
					return false;
				}
				auto StatusResponse = UStatusResponseComponent::Get(Target);
				if (IsValid(StatusResponse))
				{
					// statusComp.OnInit.BindUFunction(StatusResponse, n"OnStatusInit");
					// statusComp.OnEnd.BindUFunction(StatusResponse, n"OnStatusEnd");
					statusComp.Init(EffectData);
					return true;
				}
			}
		}
		else if (EffectTag.MatchesTag(GameplayTags::Status_Positive))
		{
			if (PositiveEffectMap.Find(EffectTag, EffectData))
			{
				return false;
			}
		}
		return false;
	}
};