class APowerManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable PowerDataTable;

	TMap<FGameplayTag, FPowerDT> PowersMap;

	TArray<FGameplayTag> BowlingPowers;
	TArray<FGameplayTag> SurvivorPowers;
	TArray<FGameplayTag> ZombiePowers;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FPowerDT> PowersArray;
		PowerDataTable.GetAllRows(PowersArray);
		for (FPowerDT Power : PowersArray)
		{
			PowersMap.Add(Power.PowerID, Power);
		}
	}

	UFUNCTION()
	void AddPower(FGameplayTag PowerID)
	{
		FPowerDT Power;
		if (PowersMap.Find(PowerID, Power) != false)
		{
			switch (Power.PowerTarget)
			{
				case EPowerTarget::Bowling:
					BowlingPowers.Add(PowerID);
					break;
				case EPowerTarget::Survivor:
					SurvivorPowers.Add(PowerID);
					break;
				case EPowerTarget::Zombie:
					ZombiePowers.Add(PowerID);
					break;
			}
		}
	}

	UFUNCTION()
	FPowerDT GetPowerData(FGameplayTag PowerID)
	{
		FPowerDT Power;
		if (PowersMap.Find(PowerID, Power) != false)
		{
			return Power;
		}
		else
		{
			PrintError("GetSurvivorData: PowerID not found");
			return Power;
		}
	}

	UFUNCTION()
	UModifier CreatePowerModifier(FModifierSpec ModifierSpec)
	{
		UModifier Mod = Cast<UModifier>(NewObject(this, ModifierSpec.Modifier.DefaultObject.Class));
		// NOTE: No ID here mean we can't remove it later. Shouldn't be a problem as we're only using it for the whole match.
		Mod.ReplaceParams(ModifierSpec.Params);
		return Mod;
	}

	UFUNCTION()
	void ApplyBowlingPower(ABowling& Bowling)
	{
		ApplyPower(Bowling.InteractSystem, BowlingPowers);
	}

	UFUNCTION()
	void ApplySurvivorPower(ASurvivor& Survivor)
	{
		ApplyPower(Survivor.InteractSystem, SurvivorPowers);
	}

	UFUNCTION()
	void ApplyZombiePower(AZombie& Zombie)
	{
		ApplyPower(Zombie.InteractSystem, ZombiePowers);
	}

	UFUNCTION()
	void ApplyBossPower(AZombieBoss& Zombie)
	{
		ApplyPower(Zombie.InteractSystem, ZombiePowers);
	}

	void ApplyPower(UInteractSystem& InteractSystem, TArray<FGameplayTag> PowerList)
	{
		for (auto PowerTag : PowerList)
		{
			FPowerDT PowerData = GetPowerData(PowerTag);
			for (auto ModifierSpec : PowerData.ModifiersSpecList)
			{
				InteractSystem.AddModifier(ModifierSpec.AffectedAttribute.GetCurrentNameOnly(),
										   CreatePowerModifier(ModifierSpec));
			}
		}
	}
};