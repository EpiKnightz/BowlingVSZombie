enum EStackingRule
{
	None,
	Stackable,
	Refreshable,
	StackAndRefreshable
}

class UStatusComponent : UActorComponent
{
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	TSubclassOf<UModifier> ModClass = UOverrideMod;

	protected int ModID = 1;

	FStatusDT StatusData;
	protected float CurrentDuration = -1;

	int InitTimes = 0;

	private UNiagaraComponent StatusEffectComp;
	// private UUIStatusBar StatusBar;

	default SetComponentTickEnabled(false);

	FVoidEvent EOnInitStatusEffect;
	FVoidEvent EOnEndStatusEffect;
	FFloatEvent EOnDurationChanged;
	FIntEvent EOnStackChanged;
	FTexture2DDelegate DAddStatusUI;

	UFUNCTION()
	bool IsApplicable()
	{
		auto TargetResponseComponent = UTargetResponseComponent::Get(GetOwner());
		if (!IsValid(TargetResponseComponent))
		{
			return false;
		}
		bool bResult = true;
		switch (StatusData.TargetType)
		{
			case ETargetType::Player:
				bResult = bResult && TargetResponseComponent.TargetType == ETargetType::Survivor;
				break;
			case ETargetType::Zombie:
				bResult = bResult && TargetResponseComponent.TargetType == ETargetType::Zombie;
				break;
			default:
		}

		if (StatusData.StackingRule == EStackingRule::None && InitTimes > 0)
		{
			bResult = false;
		}

		return bResult;
	}

	UFUNCTION()
	UStatusComponent Init(FStatusDT Row)
	{
		StatusData = Row;
		if (IsApplicable())
		{
			StatusInitCue();
			Activate(true);
			if (InitTimes == 0)
			{
				SetCurrentDuration(StatusData.Duration);
			}
			Stacking();
			DoInitChildren();
			EOnInitStatusEffect.Broadcast();
			// auto DamageResponseComponent = UDamageResponseComponent::Get(GetOwner());
			// if (IsValid(DamageResponseComponent))
			// {
			// 	DamageResponseComponent.DOnDeadCue.AddUFunction(this, n"StatusEndCue");
			// }
		}
		return this;
	}

	UFUNCTION()
	void DoInitChildren()
	{
	}

	UFUNCTION()
	void Stacking()
	{
		switch (StatusData.StackingRule)
		{
			case EStackingRule::None:
				if (InitTimes == 0)
				{
					InitTimes = 1;
				}
				break;
			case EStackingRule::Stackable:
				InitTimes++;
				EOnStackChanged.Broadcast(InitTimes);
				break;
			case EStackingRule::Refreshable:
				InitTimes = 1;
				SetCurrentDuration(StatusData.Duration);
				break;
			case EStackingRule::StackAndRefreshable:
				SetCurrentDuration(StatusData.Duration);
				InitTimes++;
				EOnStackChanged.Broadcast(InitTimes);
				break;
		}
	}

	/// Tick function called every frame. Handles decrementing the burning
	/// interval and duration, deactivating when duration expires.
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (CurrentDuration > 0)
		{
			CurrentDuration -= DeltaSeconds;
			// Print("Dur: " + CurrentDuration);
			if (CurrentDuration <= 0)
			{
				EndStatusEffect();
			}
		}
	}

	UFUNCTION()
	void EndStatusEffect()
	{
		CurrentDuration = -1;
		InitTimes = 0;
		// OnEnd.ExecuteIfBound();
		StatusEndCue();
		EOnEndStatusEffect.Broadcast();
		StatusData = FStatusDT();
		Deactivate();
		// ForceDestroyComponent(); //Warning: This could have unintended consequences.
	}

	UFUNCTION()
	float32 FindAttrValue(FName AttrName)
	{
		float outValue = AbilitySystem::INVALID_VALUE;
		if (StatusData.EffectTag.IsValid())
		{
			if (!StatusData.AffectedAttributes.Find(FGameplayTag::RequestGameplayTag(AttrName), outValue))
			{
				PrintError("Attribute not found: " + AttrName.ToString());
			}
		}
		return float32(outValue);
	}

	// Some class can't use this because the GameplaysTag::<> is not initiatiated before the editor loaded
	// Use FindAttrValue instead
	UFUNCTION()
	float32 GetAttrValue(FGameplayTag Tag)
	{
		float outValue = AbilitySystem::INVALID_VALUE;
		if (!StatusData.AffectedAttributes.Find(Tag, outValue))
		{
			PrintError("Attribute not found: " + Tag.GetTagName());
		}
		return float32(outValue);
	}

	UFUNCTION()
	void StatusInitCue()
	{
		if (!IsValid(StatusData.StatusVFX))
		{
			return;
		}

		if (!IsValid(StatusEffectComp))
		{
			if (StatusData.DurationType == EDurationType::Instant)
			{
				Niagara::SpawnSystemAtLocation(StatusData.StatusVFX, GetOwner().GetActorLocation(), GetOwner().GetActorRotation(), GetOwner().GetActorScale3D()).SetCastShadow(true);
			}
			else
			{
				StatusEffectComp = Niagara::SpawnSystemAttached(StatusData.StatusVFX, GetOwner().RootComponent, NAME_None, FVector::ZeroVector, FRotator::ZeroRotator, EAttachLocation::SnapToTargetIncludingScale, true);
			}
		}
		StatusEffectComp.SetCastShadow(true);
		StatusEffectComp.SetActive(true);
		if (InitTimes == 0)
		{
			DAddStatusUI.ExecuteIfBound(this, StatusData.Icon);
		}
	}

	UFUNCTION()
	void StatusEndCue()
	{
		if (IsActive())
		{
			if (IsValid(StatusEffectComp))
			{
				StatusEffectComp.Deactivate();
			}

			if (IsValid(StatusData.StatusEndVFX))
			{
				Niagara::SpawnSystemAtLocation(StatusData.StatusEndVFX, GetOwner().GetActorLocation(), GetOwner().GetActorRotation(), GetOwner().GetActorScale3D()).SetCastShadow(true);
			}
		}
	}

	void SetCurrentDuration(float iDuration)
	{
		CurrentDuration = iDuration;
		EOnDurationChanged.Broadcast(iDuration);
	}
}
