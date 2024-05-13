class UDamageResponseComponent : UResponseComponent
{
	FFloat2BoolDelegate DOnTakeHit;
	FFloat2BoolDelegate DOnTakeDamage;
	FFloat2BoolDelegate DOnHPRemoval;
	FFloatDelegate DOnDmgReceivedBoost;
	FBoolReturnDelegate DOnIsAlive;

	FVoidEvent DOnHitCue;
	FVoidEvent DOnDamageCue;
	FVoidEvent DOnDeadCue;

	bool bIsDead = false;

	bool InitChild() override
	{
		DOnTakeHit.BindUFunction(this, n"TakeHit");
		DOnTakeDamage.BindUFunction(this, n"TakeDamage");
		DOnHPRemoval.BindUFunction(this, n"RemoveHP");
		DOnIsAlive.BindUFunction(this, n"CheckIsAlive");
		return true;
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
		AbilitySystem.SetBaseValue(n"Damage", Damage);
		// AbilitySystem.Calculate(n"Damage");
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
			AbilitySystem.SetBaseValue(n"HP", NewHP);
			// AbilitySystem.Calculate(n"HP");
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