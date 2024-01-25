class UBurningComponent : UActorComponent
{
	float Interval;
	float CurrentInterval = -1;
	float Duration;
	float CurrentDuration = -1;
	int DamagePerInterval;

	AZombie Host;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Host = Cast<AZombie>(GetOwner());
		if (Host == nullptr)
		{
			Deactivate();
		}
	}

	UFUNCTION()
	void StartBurning(float iInterval, float iDuration, int iDamagePerInterval)
	{
		Activate();
		Interval = iInterval;
		Duration = iDuration;
		DamagePerInterval = iDamagePerInterval;
		CurrentInterval = Interval;
		CurrentDuration = Duration;
	}

	/// Tick function called every frame. Handles decrementing the burning
	/// interval and duration, deactivating when duration expires.
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (CurrentInterval > 0)
		{
			CurrentInterval -= DeltaSeconds;
			if (CurrentInterval <= 0)
			{
				CurrentDuration -= Interval;
				if (Host.UpdateHP(-DamagePerInterval) > 0 && CurrentDuration >= 0)
				{
					CurrentInterval = Interval;
				}
				else
				{
					CurrentInterval = -1;
					CurrentDuration = -1;
					Host.StatusEffect.Deactivate();
					Deactivate();
				}
			}
		}
	}
}
