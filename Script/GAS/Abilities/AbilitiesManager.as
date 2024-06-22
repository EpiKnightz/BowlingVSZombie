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
			PrintError("AbilityID not found");
			return Ability;
		}
	}
};