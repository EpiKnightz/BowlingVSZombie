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

	bool bIsDead = false;

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
		if (!bIsDead)
		{
			DOnHitCue.Broadcast();

			if (Damage > 0)
			{
				TakeDamage(Damage);
				// should not apply status here. Only return true value if the damage is taken.
				// AbilitySystem.ApplyStatusEffects(StatusEffect);
				return true;
			}
		}
		return false;
	}

	UFUNCTION()
	private bool TakeDamage(float Damage)
	{
		AbilitySystem.SetBaseValue(n"Damage", Damage, true);
		AbilitySystem.Calculate(n"Damage");
		if (CheckIsAlive())
		{
			DOnDamageCue.Broadcast();
			return true;
		}
		else
		{
			bIsDead = true;
			DOnDeadCue.Broadcast();
			return false;
		}
	}

	UFUNCTION()
	bool RemoveHP(float Amount)
	{
		if (!bIsDead)
		{
			float NewHP = AbilitySystem.GetValue(n"HP") - Amount;
			AbilitySystem.SetBaseValue(n"HP", NewHP, true);
			AbilitySystem.Calculate(n"HP");
			if (CheckIsAlive())
			{
				return true;
			}
			else
			{
				bIsDead = true;
				DOnDeadCue.Broadcast();
				return false;
			}
		}
		return false;
	}

	UFUNCTION()
	bool CheckIsAlive()
	{
		if (AbilitySystem.GetValue(n"HP") <= 0)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
};