const float BASE_WALK_SPEED = 100.f;
const float BASE_RUN_SPEED = 200.f;
class UZombieAnimInst : UCustomAnimInst
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsEmergeDone = false;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	EAttackType AtkType = EAttackType::Punch;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	float AnimMoveSpeed;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsIdle;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsRunning;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsWalking;

	// UFUNCTION(BlueprintCallable, BlueprintPure, meta = (BlueprintThreadSafe))
	bool IsIdle()
	{
		return (AnimMoveSpeed == 0);
	}

	// UFUNCTION(BlueprintCallable, BlueprintPure, meta = (BlueprintThreadSafe))
	bool IsRunning()
	{
		return (AnimMoveSpeed > BASE_WALK_SPEED);
	}

	// UFUNCTION(BlueprintCallable, BlueprintPure, meta = (BlueprintThreadSafe))
	bool IsWalking()
	{
		return (AnimMoveSpeed > 0 && AnimMoveSpeed <= BASE_WALK_SPEED);
	}

	bool IsMirroredHand()
	{
		if (AtkType == EAttackType::Area)
		{
			return !bIsMirror;
		}
		else
		{
			return bIsMirror;
		}
	}

	// Move function into varible so the animation blueprint can run on fast path
	void SetMoveSpeed(float iSpeed)
	{
		AnimMoveSpeed = iSpeed;
		bIsIdle = IsIdle();
		bIsRunning = IsRunning();
		bIsWalking = IsWalking();
		if (!bIsIdle)
		{
			if (bIsWalking)
			{
				AnimPlayRate = AnimMoveSpeed / BASE_WALK_SPEED;
			}
			else if (bIsRunning)
			{
				AnimPlayRate = AnimMoveSpeed / BASE_RUN_SPEED;
			}
		}
	}
};