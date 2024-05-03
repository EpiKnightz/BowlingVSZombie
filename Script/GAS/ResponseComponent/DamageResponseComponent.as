class UDamageResponseComponent : UActorComponent
{
	FFloat2BoolDelegate DOnTakeHit;
	FFloat2BoolDelegate DOnTakeDamage;
	FFloat2BoolDelegate DOnHPRemoval;
	FFloatDelegate DOnDmgBoost;
	FBoolReturnDelegate DOnIsAlive;

	FVoidEvent DOnHitCue;
	FVoidEvent DOnDamageCue;
	FVoidEvent DOnDeadCue;

	private UAbilitySystem AbilitySystem;

	UFUNCTION()
	void Initialize(UAbilitySystem iAbilitySystem)
	{
		if (IsValid(iAbilitySystem))
		{
			AbilitySystem = iAbilitySystem;
			DOnTakeHit.BindUFunction(this, n"TakeHit");
			DOnTakeDamage.BindUFunction(this, n"TakeDamage");
			DOnHPRemoval.BindUFunction(this, n"RemoveHP");
			DOnIsAlive.BindUFunction(this, n"CheckIsAlive");
		}
		else
		{
			PrintError("DamageResponseComponent: AbilitySystem is invalid.");
			ForceDestroyComponent();
		}
	}

	// Take Hit -> Take Damage -> Check is Alive -> DamageCue/Dead Cue
	UFUNCTION()
	bool TakeHit(float Damage)
	{
		DOnHitCue.Broadcast();

		if (Damage > 0)
		{
			TakeDamage(Damage);
			// should not apply status here. Only return true value if the damage is taken.
			// AbilitySystem.ApplyStatusEffects(StatusEffect);
			return true;
		}
		return false;
	}

	UFUNCTION()
	bool TakeDamage(float Damage)
	{
		AbilitySystem.SetCurrentValue(n"Damage", Damage);
		AbilitySystem.Calculate(n"Damage");
		if (CheckIsAlive())
		{
			DOnDamageCue.Broadcast();
			return true;
		}
		else
		{
			DOnDeadCue.Broadcast();
			return false;
		}
	}

	UFUNCTION()
	bool RemoveHP(float Amount)
	{
		float NewHP = AbilitySystem.GetCurrentValue(n"HP") - Amount;
		AbilitySystem.SetCurrentValue(n"HP", NewHP);
		AbilitySystem.Calculate(n"HP");
		if (CheckIsAlive())
		{
			return true;
		}
		else
		{
			DOnDeadCue.Broadcast();
			return false;
		}
	}

	UFUNCTION()
	bool CheckIsAlive()
	{
		if (AbilitySystem.GetCurrentValue(n"HP") <= 0)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
};