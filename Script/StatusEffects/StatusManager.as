class AStatusManager : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(BlueprintReadWrite)
	UDataTable EffectDataTable;

	FTagStatusCompEvent EOnStatusApplied;

	TMap<FGameplayTag, FStatusDT> EffectMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FStatusDT> StatusEffectArray;
		EffectDataTable.GetAllRows(StatusEffectArray);
		for (FStatusDT Status : StatusEffectArray)
		{
			EffectMap.Add(Status.EffectTag, Status);
		}
	}

	UFUNCTION()
	FStatusDT GetStatusData(FGameplayTag StatusTag)
	{
		FStatusDT StatusData;
		if (EffectMap.Find(StatusTag, StatusData) != false)
		{
			return StatusData;
		}
		else
		{
			PrintError("GetStatusData: StatusID " + StatusTag + " not found");
			return StatusData;
		}
	}

	UFUNCTION()
	bool ApplyStatusEffects(FGameplayTagContainer EffectTags, AActor Target)
	{
		if (EffectTags.IsEmpty() || !IsValid(Target))
		{
			return false;
		}

		auto DamageResponseComponent = UDamageResponseComponent::Get(Target);
		UUIStatusBar StatusBar;

		UWidgetComponent WidgetComponent = UWidgetComponent::Get(Target, n"StatusWorldWidget");
		if (IsValid(WidgetComponent))
		{
			StatusBar = Cast<UUIStatusBar>(WidgetComponent.GetWidget());
		}

		if (IsValid(DamageResponseComponent) && !DamageResponseComponent.bIsDead && !EffectTags.IsEmpty())
		{
			int errorCount = 0;
			for (FGameplayTag SingleEffect : EffectTags.GameplayTags)
			{
				if (!ApplySingleEffect(SingleEffect, Target, DamageResponseComponent, StatusBar))
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
	bool ApplySingleEffect(FGameplayTag EffectTag, AActor Target, UDamageResponseComponent DRC, UUIStatusBar StatusBar)
	{
		UStatusComponent statusComp;
		FStatusDT EffectData;
		if (EffectMap.Find(EffectTag, EffectData))
		{
			statusComp = Target.GetOrCreateComponent(EffectData.StatusEffectClass);
			if (IsValid(StatusBar))
			{
				statusComp.DAddStatusUI.BindUFunction(StatusBar, n"AddStatus");
			}
			statusComp.Init(EffectData);
			DRC.EOnDeadCue.AddUFunction(statusComp, n"EndStatusEffect");
			EOnStatusApplied.Broadcast(EffectTag, statusComp);
			return true;
		}
		return false;
	}
};