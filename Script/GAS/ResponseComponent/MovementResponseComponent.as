class UMovementResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeMoveSpeedModifier;
	FObjectIntDelegate DOnRemoveMoveSpeedModifier;
	FModDelegate DOnChangeAccelModifier;
	FObjectIntDelegate DOnRemoveAccelModifier;
	FVectorEvent EOnAddForceCue;
	FHitResultEvent EOnBounceCue;
	FVoidDelegate DOnStopTimeReached;

	UProjectileMovementComponent MovementComp;

	float StopLifeTime = 1;
	float StopTimeCounter = 0;
	float StopThreshold = 1000;
	private float LocalAccel = 0;
	private const float WorldDeaccel = -500;
	// private bool bIsAccelable = true;
	FVector AddedVelocity = FVector::ZeroVector;

	bool InitChild() override
	{
		MovementComp = UProjectileMovementComponent::Get(Owner);
		if (MovementComp == nullptr)
		{
			PrintError("MovementResponseComponent requires ProjectileMovementComponent");
			return false;
		}
		DOnChangeMoveSpeedModifier.BindUFunction(this, n"OnChangeMoveSpeedModifier");
		DOnRemoveMoveSpeedModifier.BindUFunction(this, n"OnRemoveMoveSpeedModifier");
		DOnChangeAccelModifier.BindUFunction(this, n"OnChangeAccelModifier");
		DOnRemoveAccelModifier.BindUFunction(this, n"OnRemoveAccelModifier");
		EOnAddForceCue.AddUFunction(this, n"AddForce");

		MovementComp.OnProjectileBounce.AddUFunction(this, n"ActorBounce");

		ComponentTickInterval = 0.05;
		return true;
	}

	void InitForce(FVector Direction, float Force)
	{
		if (Direction.IsZero() || Force == 0)
		{
			PrintError("MovementResponseComponent::InitForce: Direction or Force is zero");
			return;
		}
		ComponentTickEnabled = true;
		// MovementComp.InitialSpeed = Force;
		MovementComp.Velocity = Direction * Force;
		MovementComp.Activate();
	}

	// void SetIsAccelable(bool IsAccelable)
	// {
	// 	bIsAccelable = IsAccelable;
	// }

	UFUNCTION()
	private void OnChangeMoveSpeedModifier(UModifier Modifier){
		AbilitySystem.AddModifier(n"MoveSpeed", Modifier);
	}
	UFUNCTION()
	private void OnRemoveMoveSpeedModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(n"MoveSpeed", Object, ID);
	}

	UFUNCTION()
	private void OnChangeAccelModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(n"Accel", Modifier);
	}

	UFUNCTION()
	private void OnRemoveAccelModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(n"Accel", Object, ID);
	}

	UFUNCTION()
	private void AddForce(FVector VelocityVector)
	{
		MovementComp.Velocity += VelocityVector * AbilitySystem.GetValue(n"Bounciness");
	}

	UFUNCTION()
	void ActorBounce(const FHitResult&in Hit, const FVector&in ImpactVelocity)
	{
		MovementComp.Velocity *= AbilitySystem.GetValue(n"Bounciness");
		auto MovementResponse = UMovementResponseComponent::Get(Hit.GetActor());
		if (IsValid(MovementResponse))
		{
			MovementResponse.EOnAddForceCue.Broadcast(ImpactVelocity);
		}

		EOnBounceCue.Broadcast(Hit);
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		LocalAccel = AbilitySystem.GetValue(n"Accel");
		if (LocalAccel == 0 || LocalAccel == AbilitySystem::INVALID_VALUE)
		{
			LocalAccel = WorldDeaccel;
		}
		MovementComp.Velocity += MovementComp.Velocity.GetSafeNormal() * LocalAccel * DeltaSeconds;

		if (LocalAccel < 0 && MovementComp.Velocity.SizeSquared() <= StopThreshold && MovementComp.Velocity != FVector::ZeroVector)
		{
			MovementComp.StopMovementImmediately();
			StopTimeCounter = 0;
		}

		if (MovementComp.Velocity == FVector::ZeroVector)
		{
			CountStopTimer(DeltaSeconds);
		}
	}

	void CountStopTimer(float DeltaSeconds)
	{
		if (StopLifeTime > 0 && StopTimeCounter >= 0)
		{
			StopTimeCounter += DeltaSeconds;
			if (StopTimeCounter >= StopLifeTime)
			{
				StopTimeCounter = -1;
				DOnStopTimeReached.ExecuteIfBound();
			}
		}
	}
};