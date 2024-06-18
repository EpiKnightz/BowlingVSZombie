const float IDLE_TIME_TO_STRETCH = 5;

class UHamsterAnimInst : UCustomAnimInst
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsIdle = true;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsStreching = false;

	private float CurrentIdleTime;

	void SetIdle(bool bNewIdle)
	{
		bIsIdle = bNewIdle;
	}

	UFUNCTION(BlueprintOverride)
	void BlueprintUpdateAnimation(float DeltaTimeX)
	{
		if (bIsIdle)
		{
			CurrentIdleTime += DeltaTimeX;
			if (CurrentIdleTime > IDLE_TIME_TO_STRETCH)
			{
				bIsIdle = false;
				bIsStreching = true;
				CurrentIdleTime = 0;
			}
		}
		else if (bIsStreching)
		{
			CurrentIdleTime += DeltaTimeX;
			if (CurrentIdleTime > IDLE_TIME_TO_STRETCH)
			{
				bIsIdle = true;
				bIsStreching = false;
				CurrentIdleTime = 0;
			}
		}
	}
};