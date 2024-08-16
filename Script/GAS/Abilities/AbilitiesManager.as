class AAbilitiesManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable AbilitiesDataTable;

	TMap<FGameplayTag, FAbilityDT> AbilitiesData;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FAbilityDT> AbilitiesArray;
		AbilitiesDataTable.GetAllRows(AbilitiesArray);
		for (FAbilityDT Ability : AbilitiesArray)
		{
			AbilitiesData.Add(Ability.AbilityID, Ability);
		}
	}

	UFUNCTION()
	FAbilityDT GetAbilityData(FGameplayTag AbilityID)
	{
		FAbilityDT Ability;
		if (AbilitiesData.Find(AbilityID, Ability) != false)
		{
			return Ability;
		}
		else
		{
			PrintError("GetAbilityData: AbilityID not found");
			return Ability;
		}
	}

	UFUNCTION()
	void RegisterAbilities(FGameplayTagContainer AbilitiesContainer, ULiteAbilitySystem& AbilitySystem)
	{
		for (FGameplayTag AbilityID : AbilitiesContainer.GameplayTags)
		{
			RegisterSingleAbility(AbilityID, AbilitySystem);
		}
	}

	UFUNCTION()
	void RegisterSingleAbility(FGameplayTag AbilityID, ULiteAbilitySystem& AbilitySystem)
	{
		if (AbilityID.MatchesTag(GameplayTags::Ability_Shoot_AtTarget))
		{
			AbilitySystem.RegisterAbility(UShootAtTargetAbility, AbilityID);
		}
		else if (AbilityID.MatchesTag(GameplayTags::Ability_Shoot))
		{
			AbilitySystem.RegisterAbility(UShootBulletAbility, AbilityID);
		}
		else if (AbilityID.MatchesTag(GameplayTags::Ability_Slash))
		{
			AbilitySystem.RegisterAbility(USlashAreaAbility, AbilityID);
		}
		else if (AbilityID.MatchesTag(GameplayTags::Ability_MultiShoot))
		{
			AbilitySystem.RegisterAbility(UMultiShootAbility, AbilityID);
		}
		else if (AbilityID.MatchesTag(GameplayTags::Ability_Grow))
		{
			AbilitySystem.RegisterAbility(UGrowUpAbility, AbilityID);
		}
		else
		{
			PrintError("RegisterSingleAbility: AbilityID not found");
		}
	}
};