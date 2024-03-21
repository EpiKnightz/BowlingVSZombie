class UStatusComponent : UActorComponent
{
	float Duration;
	float CurrentDuration = -1;

	int InitTimes = 0;

	FNiagaraDelegate OnInit;
	FVoidDelegate OnEnd;

	AActor Host;

	UFUNCTION()
	bool IsApplicable()
	{
		return true;
	}

	UFUNCTION()
	UStatusComponent Init(FStatusDT Row)
	{
		Host = GetOwner();
		OnInit.ExecuteIfBound(Row.StatusVFX);
		Activate();
		Duration = Row.Duration;
		CurrentDuration = Duration;
		InitTimes++;
		DoInitChildren(Row.Param1, Row.Param2);
		return this;
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
		OnEnd.ExecuteIfBound();
		Deactivate();
		// ForceDestroyComponent(); //Warning: This could have unintended consequences.
	}
}
