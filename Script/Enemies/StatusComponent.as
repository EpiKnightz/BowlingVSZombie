class UStatusComponent : UActorComponent
{
	FName ComponentName;

	float Duration;
	float CurrentDuration = -1;

	int InitTimes = 0;

	AZombie Host;

	UFUNCTION()
	bool IsApplicable()
	{
		return true;
	}

	UFUNCTION()
	void Init(FZombieStatusDT Row)
	{
		Host = Cast<AZombie>(GetOwner());
		if (Host != nullptr && IsApplicable())
		{
			Host.StatusEffect.Asset = Row.StatusVFX;
			Host.StatusEffect.Activate(true);
			Activate();
			Duration = Row.Duration;
			CurrentDuration = Duration;
			InitTimes++;
			DoInitChildren(Row.Param1, Row.Param2);
		}
		else
		{
			Deactivate();
		}
	}

	UFUNCTION()
	void DoInitChildren(float iParam1, float iParam2)
	{
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
		Host.StatusEffect.Deactivate();
		Deactivate();
		// ForceDestroyComponent(); //Warning: This could have unintended consequences.
	}
}
