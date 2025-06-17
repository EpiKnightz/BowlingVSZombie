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
	void RegisterAbilities(FGameplayTagContainer AbilitiesContainer, UInteractSystem& InteractSystem)
	{
		for (FGameplayTag AbilityID : AbilitiesContainer.GameplayTags)
		{
			RegisterSingleAbility(AbilityID, InteractSystem);
		}
	}

	UFUNCTION()
	TArray<int> RegisterAbilitiesRetIDs(FGameplayTagContainer AbilitiesContainer, UInteractSystem& InteractSystem)
	{
		TArray<int> RegisterID;
		for (FGameplayTag AbilityID : AbilitiesContainer.GameplayTags)
		{
			RegisterID.Add(RegisterSingleAbility(AbilityID, InteractSystem));
		}
		return RegisterID;
	}

	UFUNCTION()
	int RegisterAbilitiesFirstID(FGameplayTagContainer AbilitiesContainer, UInteractSystem& InteractSystem)
	{
		int RegisterID = -1;
		for (FGameplayTag AbilityID : AbilitiesContainer.GameplayTags)
		{
			if (RegisterID == -1)
			{
				RegisterID = RegisterSingleAbility(AbilityID, InteractSystem);
			}
			else
			{
				RegisterSingleAbility(AbilityID, InteractSystem);
			}
		}
		return RegisterID;
	}

	UFUNCTION()
	int RegisterSingleAbility(FGameplayTag AbilityID, UInteractSystem& InteractSystem)
	{
		FAbilityDT AbilityData = GetAbilityData(AbilityID);
		if (AbilityData.AbilityClass.IsValid())
		{
			return InteractSystem.RegisterAbility(AbilityData.AbilityClass, AbilityID);
		}
		else
		{
			PrintError("RegisterSingleAbility: " + AbilityID + " not found");
			return -1;
		}
	}
};