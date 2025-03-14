class UDamageResponseComponent : UResponseComponent
{
	FFloatTag2BoolDelegate DOnTakeHit;
	FFloatTag2BoolDelegate DOnTakeDamage;
	FFloat2BoolDelegate DOnHPRemoval;
	FFloat2BoolDelegate DOnHPPercentRemoval;
	FFloatDelegate DOnDmgReceivedBoost;
	FBoolReturnDelegate DOnIsAlive;

	FVoidEvent EOnHitCue;
	FVoidEvent EOnDamageCue;
	FVoidEvent EOnHealCue;
	FVoidEvent EOnDeadCue;

	FVoidEvent EOnEnterTheBattlefield;
	FVoidEvent EOnNewCardAdded;

	bool bIsDead = false;
	bool bIsKnockbackResisted = false;

	TMap<FGameplayTag, FName> WeaknessMap;

	bool InitChild() override
	{
		DOnTakeHit.BindUFunction(this, n"TakeHit");
		DOnTakeDamage.BindUFunction(this, n"TakeDamage");
		DOnHPRemoval.BindUFunction(this, n"RemoveHP");
		DOnHPPercentRemoval.BindUFunction(this, n"RemoveHPPercent");
		DOnIsAlive.BindUFunction(this, n"CheckIsAlive");
		WeaknessMap.Add(GameplayTags::Description_Element_Void, WeaknessAttrSet::VoidWeaknessMultiplier);
		WeaknessMap.Add(GameplayTags::Description_Element_Fire, WeaknessAttrSet::FireWeaknessMultiplier);
		WeaknessMap.Add(GameplayTags::Description_Element_Water, WeaknessAttrSet::WaterWeaknessMultiplier);
		WeaknessMap.Add(GameplayTags::Description_Element_Forest, WeaknessAttrSet::ForestWeaknessMultiplier);
		WeaknessMap.Add(GameplayTags::Description_Element_Earth, WeaknessAttrSet::EarthWeaknessMultiplier);
		WeaknessMap.Add(GameplayTags::Description_Element_Aether, WeaknessAttrSet::AetherWeaknessMultiplier);
		WeaknessMap.Add(GameplayTags::Description_Element_Nether, WeaknessAttrSet::NetherWeaknessMultiplier);
		return true;
	}

	// Take Hit -> Take Damage -> Check is Alive -> DamageCue/Dead Cue
	UFUNCTION()
	bool TakeHit(float Damage, FGameplayTag Element = GameplayTags::Description_Element_Void)
	{
		if (!bIsDead)
		{
			if (Damage > (AbilitySystem.HasAttrSet(MovementAttrSet::KnockbackResistance) ? AbilitySystem.GetValue(MovementAttrSet::KnockbackResistance) : 0))
			{
				EOnHitCue.Broadcast();
			}
			else if (Damage > 0)
			{
				bIsKnockbackResisted = true;
				// System::SetTimer(this, n"ResetKnockbackResistance", 0.05f, false);
				System::SetTimerForNextTick(this, "ResetKnockbackResistance");
			}

			if (Damage > 0)
			{
				TakeDamage(Damage, Element);
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
	private bool TakeDamage(float Damage, FGameplayTag Element = GameplayTags::Description_Element_Void)
	{
		if (!bIsDead)
		{
			AbilitySystem.SetBaseValue(PrimaryAttrSet::Damage, CalculateWeakness(Damage, Element));
			// AbilitySystem.Calculate(PrimaryAttrSet::Damage);
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
	float CalculateWeakness(float Damage, FGameplayTag Element)
	{
		if (AbilitySystem.HasAttrSet(WeaknessAttrSet::VoidWeaknessMultiplier))
		{
			return Damage * AbilitySystem.GetValue(WeaknessMap[Element]);
		}
		return Damage;
	}

	UFUNCTION()
	bool TakeHeal(float Heal)
	{
		if (!bIsDead)
		{
			float NewHP = AbilitySystem.GetValue(PrimaryAttrSet::HP) + Heal;
			AbilitySystem.SetBaseValue(PrimaryAttrSet::HP, NewHP);
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
			float NewHP = AbilitySystem.GetValue(PrimaryAttrSet::HP) - Amount;
			AbilitySystem.SetBaseValue(PrimaryAttrSet::HP, NewHP);
			// AbilitySystem.Calculate(PrimaryAttrSet::HP);
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
		float Amount = AbilitySystem.GetValue(PrimaryAttrSet::MaxHP) * Value;
		return (RemoveHP(Amount));
	}

	UFUNCTION()
	bool CheckIsAlive()
	{
		if (AbilitySystem.GetValue(PrimaryAttrSet::HP) <= 0)
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
		float HP = AbilitySystem.GetValue(PrimaryAttrSet::HP);
		return (HP > 0 && HP < AbilitySystem.GetValue(PrimaryAttrSet::MaxHP));
	}

	UFUNCTION()
	void ResetKnockbackResistance()
	{
		bIsKnockbackResisted = false;
	}

	UFUNCTION()
	bool IsKnockbackResisted()
	{
		if (bIsKnockbackResisted)
		{
			bIsKnockbackResisted = false;
			return true;
		}
		return false;
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