class UAttackResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeAttackModifier;
	FObjectIntDelegate DOnRemoveAttackModifier;
	FModDelegate DOnChangeAttackCooldownModifier;
	FObjectIntDelegate DOnRemoveAttackCooldownModifier;

	FVectorReturnDelegate DGetAttackLocation;
	FRotatorReturnDelegate DGetAttackRotation;

	FVoidEvent EOnAnimHitNotify;
	FVoidDelegate DPlayAttackAnim;
	FActorEvent EOnBeginOverlapEvent;
	FName2VectorDelegate DGetSocketLocation;

	bool InitChild() override
	{

		DOnChangeAttackModifier.BindUFunction(this, n"OnChangeAttackModifier");
		DOnRemoveAttackModifier.BindUFunction(this, n"OnRemoveAttackModifier");
		DOnChangeAttackCooldownModifier.BindUFunction(this, n"OnChangeAttackCooldownModifier");
		DOnRemoveAttackCooldownModifier.BindUFunction(this, n"OnRemoveAttackCooldownModifier");
		return true;
	}

	UFUNCTION()
	private void OnRemoveAttackCooldownModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(n"AttackCooldown", Object, ID);
	}

	UFUNCTION()
	private void OnChangeAttackCooldownModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(n"AttackCooldown", Modifier);
	}

	UFUNCTION()
	void OnChangeAttackModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(n"Attack", Modifier);
	}

	UFUNCTION()
	void OnRemoveAttackModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(n"Attack", Object, ID);
	}

	UFUNCTION()
	void NotifyAttackHit()
	{
		EOnAnimHitNotify.Broadcast();
	}
};