class UMovementResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeMoveSpeedModifier;
	FObjectIntDelegate DOnRemoveMoveSpeedModifier;
	FModDelegate DOnChangeAccelModifier;
	FObjectIntDelegate DOnRemoveAccelModifier;
	FVectorEvent EOnAddForceCue;

	FHitResultEvent EOnBounceCue;

	UProjectileMovementComponent MovementComp;

	bool InitChild() override
	{
		MovementComp = UProjectileMovementComponent::Get(Owner);
		if (MovementComp == nullptr)
		{
			PrintError("MovementResponseComponent requires ProjectileMovementComponent");
		}
		DOnChangeMoveSpeedModifier.BindUFunction(this, n"OnChangeMoveSpeedModifier");
		DOnRemoveMoveSpeedModifier.BindUFunction(this, n"OnRemoveMoveSpeedModifier");
		DOnChangeAccelModifier.BindUFunction(this, n"OnChangeAccelModifier");
		DOnRemoveAccelModifier.BindUFunction(this, n"OnRemoveAccelModifier");
		EOnAddForceCue.AddUFunction(this, n"AddForce");
		return true;
	}

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
};