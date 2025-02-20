class UMovementResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeMoveSpeedModifier;
	FObjectIntDelegate DOnRemoveMoveSpeedModifier;
	FModDelegate DOnChangeAccelModifier;
	FObjectIntDelegate DOnRemoveAccelModifier;
	FVectorDelegate DOnAddForce;
	FVectorEvent EOnPreAddForceCue;
	FVoidEvent EOnPostAddForce;
	FHitResultEvent EOnBounceCue;
	FVoidEvent EOnPostBounce;
	FVoidEvent EOnPierceCue;
	FVoidDelegate DOnStopTimeReached;
	FVoidEvent EOnStopCue;
	FVoidEvent EOnDeaccelTick;

	UProjectileMovementComponent MovementComp;

	float StopLifeTime = 2;
	float StopTimeCounter = 0;
	float StopThreshold = 4900;
	private float LocalAccel = 0;
	private const float WorldDeaccel = -500;
	private bool bIsAccelable = true;
	FVector AddedVelocity = FVector::ZeroVector;
	bool bIsBouncable = true;

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
		DOnAddForce.BindUFunction(this, n"AddForce");

		MovementComp.OnProjectileBounce.AddUFunction(this, n"ActorBounce");

		AbilitySystem.EOnPostCalculation.AddUFunction(this, n"OnPostCalculation");

		ComponentTickInterval = 0.05;
		return true;
	}

	void InitForce(FVector Direction, float Force)
	{
		if (Direction.IsZero() || Force == 0)
		{
			PrintWarning("MovementResponseComponent::InitForce: Direction or Force is zero");
			return;
		}
		ComponentTickEnabled = true;
		// MovementComp.InitialSpeed = Force;
		MovementComp.Velocity = Direction * Force;
		MovementComp.Activate();
	}

	UFUNCTION()
	void EnableMovement(bool bEnable)
	{
		if (bEnable)
		{
			MovementComp.Activate();
		}
		else
		{
			MovementComp.Deactivate();
		}
	}

	void SetIsAccelable(bool IsAccelable)
	{
		if (IsAccelable)
		{
			MovementComp.MaxSpeed = AbilitySystem.GetValue(MovementAttrSet::MoveSpeed);
		}
		else
		{
			MovementComp.MaxSpeed = 5000;
		}
		bIsAccelable = IsAccelable;
	}

	void SetIsBouncable(bool IsBouncable)
	{
		// MovementComp.bShouldBounce = IsBouncable;
		bIsBouncable = IsBouncable;
	}

	UFUNCTION()
	private void OnChangeMoveSpeedModifier(UModifier Modifier){
		AbilitySystem.AddModifier(MovementAttrSet::MoveSpeed, Modifier);
	}
	UFUNCTION()
	private void OnRemoveMoveSpeedModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(MovementAttrSet::MoveSpeed, Object, ID);
	}

	UFUNCTION()
	private void OnChangeAccelModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(MovementAttrSet::Accel, Modifier);
	}

	UFUNCTION()
	private void OnRemoveAccelModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(MovementAttrSet::Accel, Object, ID);
	}

	// Called when being bounced by another actor.
	UFUNCTION()
	private void AddForce(FVector VelocityVector)
	{
		if (!VelocityVector.IsZero() && bIsBouncable)
		{
			EOnPreAddForceCue.Broadcast(VelocityVector);
			MovementComp.Velocity += VelocityVector * AbilitySystem.GetValue(MovementAttrSet::Bounciness);
			EOnPostAddForce.Broadcast();
		}
	}

	// Happen natually when the projectile hits something.
	UFUNCTION()
	void ActorBounce(const FHitResult&in Hit, const FVector&in ImpactVelocity)
	{
		if (!ImpactVelocity.IsZero())
		{
			EOnBounceCue.Broadcast(Hit);
			auto MovementResponse = UMovementResponseComponent::Get(Hit.GetActor());
			if (IsValid(MovementResponse) && MovementResponse.bIsBouncable)
			{
				// This bounciness will be multiplier to the already existing bounciness of Movement Component. (default is 0.8)
				float Bounciness = AbilitySystem.GetValue(MovementAttrSet::Bounciness);
				MovementComp.Velocity *= AbilitySystem.GetValue(MovementAttrSet::Bounciness);
				MovementResponse.DOnAddForce.ExecuteIfBound(ImpactVelocity);
				// Print("ActorBounce: " + Hit.GetActor().GetName() + " with " + ImpactVelocity.ToString() + " result in:" + MovementComp.Velocity.ToString(), 100);
			}

			EOnPostBounce.Broadcast();
		}
	}

	UFUNCTION()
	private void OnPostCalculation(FName AttrName, float Value)
	{
		if (AttrName == MovementAttrSet::MoveSpeed)
		{
			MovementComp.MaxSpeed = Value;
		}
	}

	UFUNCTION()
	void ActorPierce(AActor OtherActor)
	{
		EOnPierceCue.Broadcast();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (!bIsAccelable)
		{
			LocalAccel = WorldDeaccel;
			EOnDeaccelTick.Broadcast();
		}
		else
		{
			LocalAccel = AbilitySystem.GetValue(MovementAttrSet::Accel);
			if (LocalAccel == 0 || LocalAccel == AbilitySystem::INVALID_VALUE)
			{
				LocalAccel = WorldDeaccel;
				EOnDeaccelTick.Broadcast();
			}
		}
		MovementComp.Velocity += MovementComp.Velocity.GetSafeNormal() * LocalAccel * DeltaSeconds;

		if (LocalAccel < 0 && MovementComp.Velocity.SizeSquared() <= StopThreshold && MovementComp.Velocity != FVector::ZeroVector)
		{
			MovementComp.StopMovementImmediately();
			StopTimeCounter = 0;
			EOnStopCue.Broadcast();
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