class UDamageResponseComponent : UResponseComponent
{
	FFloat2BoolDelegate DOnTakeHit;
	FFloat2BoolDelegate DOnTakeDamage;
	FFloat2BoolDelegate DOnHPRemoval;
	FFloat2BoolDelegate DOnHPPercentRemoval;
	FFloatDelegate DOnDmgReceivedBoost;
	FBoolReturnDelegate DOnIsAlive;

	FVoidEvent EOnHitCue;
	FVoidEvent EOnDamageCue;
	FVoidEvent EOnHealCue;
	FVoidEvent EOnDeadCue;

	FVoidEvent EOnEnterTheBattlefield;

	bool bIsDead = false;

	bool InitChild() override
	{
		DOnTakeHit.BindUFunction(this, n"TakeHit");
		DOnTakeDamage.BindUFunction(this, n"TakeDamage");
		DOnHPRemoval.BindUFunction(this, n"RemoveHP");
		DOnHPPercentRemoval.BindUFunction(this, n"RemoveHPPercent");
		DOnIsAlive.BindUFunction(this, n"CheckIsAlive");
		return true;
	}

	// Take Hit -> Take Damage -> Check is Alive -> DamageCue/Dead Cue
	UFUNCTION()
	bool TakeHit(float Damage)
	{
		if (!bIsDead)
		{
			if (Damage > 0)
			{
				EOnHitCue.Broadcast();
			}

			if (Damage > 0)
			{
				TakeDamage(Damage);
				// should not apply status here. Only return true value if the damage is taken.
				// AbilitySystem.ApplyStatusEffects(StatusEffect);
				return true;
			}
			else if (Damage < 0)
			{
				TakeHeal(-Damage);
			}
		}
		return false;
	}

	UFUNCTION()
	private bool TakeDamage(float Damage)
	{
		if (!bIsDead)
		{
			AbilitySystem.SetBaseValue(n"Damage", Damage);
			// AbilitySystem.Calculate(n"Damage");
			if (CheckIsAlive())
			{
				EOnDamageCue.Broadcast();
				return true;
			}
			else
			{
				HandleDeadLogic();
				return false;
			}
		}
		return false;
	}

	UFUNCTION()
	bool TakeHeal(float Heal)
	{
		if (!bIsDead)
		{
			float NewHP = AbilitySystem.GetValue(n"HP") + Heal;
			AbilitySystem.SetBaseValue(n"HP", NewHP);
			EOnHealCue.Broadcast();
			return true;
		}
		return false;
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
				HandleDeadLogic();
				return false;
			}
		}
		return false;
	}

	UFUNCTION()
	private bool RemoveHPPercent(float Value)
	{
		float Amount = AbilitySystem.GetValue(n"MaxHP") * Value;
		return (RemoveHP(Amount));
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

	UFUNCTION()
	bool IsDamaged()
	{
		float HP = AbilitySystem.GetValue(n"HP");
		return (HP > 0 && HP < AbilitySystem.GetValue(n"MaxHP"));
	}

	UFUNCTION()
	void HandleDeadLogic()
	{
		bIsDead = true;
		DOnTakeHit.Clear();
		DOnTakeDamage.Clear();
		DOnHPRemoval.Clear();
		DOnHPPercentRemoval.Clear();
		EOnDeadCue.Broadcast();
		EOnDeadCue.Clear();
	}
};