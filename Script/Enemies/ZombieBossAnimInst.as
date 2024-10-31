const float BASE_WALK_SPEED = 150.f;
const float BASE_RUN_SPEED = 300.f;

enum EMoveDirection
{
	None = 0,
	Backward = 1,
	Forward = 2,
	Left = 3,
	Right = 4,
}

class UZombieBossAnimInst : UCustomAnimInst
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsEmergeDone = false;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	float AnimMoveSpeed;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsIdle;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsRunning;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsWalking;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	EMoveDirection MoveDirection = EMoveDirection::None;

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

	bool IsForward()
	{
		return (MoveDirection == EMoveDirection::Forward);
	}

	bool IsBackwardOrSideway()
	{
		return (MoveDirection == EMoveDirection::Backward
				|| MoveDirection == EMoveDirection::Left
				|| MoveDirection == EMoveDirection::Right);
	}

	void OppositeMoveDirection()
	{
		switch (MoveDirection)
		{
			case EMoveDirection::Forward:
				MoveDirection = EMoveDirection::Backward;
				break;
			case EMoveDirection::Backward:
				MoveDirection = EMoveDirection::Forward;
				break;
			case EMoveDirection::Left:
				MoveDirection = EMoveDirection::Right;
				break;
			case EMoveDirection::Right:
				MoveDirection = EMoveDirection::Left;
				break;
			default:
				break;
		}
	}

	void RandomizeMoveDirection()
	{
		MoveDirection = EMoveDirection(Math::RandRange(3, 4));
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