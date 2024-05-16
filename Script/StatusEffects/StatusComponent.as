enum EStackingRule
{
	None,
	Stackable,
	Refreshable,
	StackAndRefreshable
}

class UStatusComponent : UActorComponent
{
	protected int ModID = 1;

	FStatusDT StatusData;
	protected float CurrentDuration = -1;

	int InitTimes = 0;

	private UNiagaraComponent StatusEffectComp;

	default SetComponentTickEnabled(false);

	// FVoidDelegate OnInit;
	// FVoidDelegate OnEnd;

	UFUNCTION()
	bool IsApplicable()
	{
		bool bResult = true;

		switch (StatusData.TargetType)
		{
			case ETargetType::Player:
				bResult = bResult && (GetOwner().IsA(ABowlingPawn));
				break;
			case ETargetType::Zombie:
				bResult = bResult && (GetOwner().IsA(AZombie));
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
			Activate();
			if (InitTimes == 0)
			{
				CurrentDuration = StatusData.Duration;
			}
			Stacking();
			DoInitChildren();
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
				break;
			case EStackingRule::Refreshable:
				CurrentDuration = StatusData.Duration;
				break;
			case EStackingRule::StackAndRefreshable:
				CurrentDuration = StatusData.Duration;
				InitTimes++;
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
		StatusData = FStatusDT();
		Deactivate();
		// ForceDestroyComponent(); //Warning: This could have unintended consequences.
	}

	UFUNCTION()
	float32 FindAttrValue(FName AttrName)
	{
		float outValue = -1000;
		if (!StatusData.AffectedAttributes.Find(FGameplayTag::RequestGameplayTag(AttrName), outValue))
		{
			PrintError("Attribute not found: " + AttrName.ToString());
		}
		return float32(outValue);
	}

	UFUNCTION()
	float GetAttrValue(FGameplayTag Tag)
	{
		float outValue = -1000;
		if (!StatusData.AffectedAttributes.Find(Tag, outValue))
		{
			PrintError("Attribute not found: " + Tag.GetTagName());
		}
		return outValue;
	}

	UFUNCTION()
	void StatusInitCue()
	{
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
}
