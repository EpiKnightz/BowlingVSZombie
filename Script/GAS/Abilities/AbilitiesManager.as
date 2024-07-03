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
		if (AbilityID.MatchesTag(GameplayTags::Ability_ShootAtTarget))
		{
			AbilitySystem.RegisterAbility(UShootAtTargetAbility);
		}
		else if (AbilityID.MatchesTag(GameplayTags::Ability_ShootOnOverlap))
		{
			AbilitySystem.RegisterAbility(UShootOnOverlapAbility);
		}
		else if (AbilityID.MatchesTag(GameplayTags::Ability_SlashOnOverlap))
		{
			AbilitySystem.RegisterAbility(USlashOnOverlapAbility);
		}
		else if (AbilityID.MatchesTag(GameplayTags::Ability_MultiShootOnOverlap))
		{
			AbilitySystem.RegisterAbility(UMultiShootOnOverlapAbility);
		}
		else
		{
			PrintError("RegisterSingleAbility: AbilityID not found");
		}
	}
};