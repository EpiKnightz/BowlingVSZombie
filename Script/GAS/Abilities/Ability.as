class UAbility : ULiteAbilityBase
{
	// Requirements
	// - Attribute Cost
	// - Cooldown- Which could also be a attribute cost

	ULiteAbilitySystem AbilitySystem;

	FGameplayTag AbilityID;

	FGameplayTagContainer AbilityTags;

	protected AAbilitiesManager AbilitiesManager;
	protected FAbilityDT AbilityData;
	protected int Key;

	UFUNCTION(BlueprintOverride)
	void PostRegisterAbility(const ULiteAbilitySystemComponent iAbilitySystem, int iKey)
	{
		Key = iKey;
		AbilitySystem = Cast<ULiteAbilitySystem>(iAbilitySystem);
		if (IsValid(AbilitySystem))
		{
			AbilitiesManager = Gameplay::GetActorOfClass(AAbilitiesManager);
			if (IsValid(AbilitiesManager))
			{
				if (SetupAbilityChild())
				{
					return;
				}
			}
		}

		// If all above fails, need to print error and deregister the ability
		{
			PrintError("Failed to register ability");
			RemoveAbility();
		}
	}

	UFUNCTION()
	void GetAbilityData()
	{
		AbilityData = AbilitiesManager.GetAbilityData(AbilityID);
	}

	UFUNCTION()
	bool SetupAbilityChild()
	{
		return true;
	}

	// UFUNCTION()
	// bool CanActivate()
	// {
	// 	return true;
	// }

	// UFUNCTION()
	// bool ActivateAbility()
	// {
	// 	if (CanActivate())
	// 	{
	// 		return ActivateAbilityChild();
	// 	}
	// 	else
	// 	{
	// 		StopAbility();
	// 		return false;
	// 	}
	// }

	// UFUNCTION()
	// bool ActivateAbilityChild()
	// {
	// 	return true;
	// }

	UFUNCTION()
	void StopAbility()
	{}

	UFUNCTION()
	void RemoveAbility()
	{
		AbilitySystem.DeregAbility(Key);
	}
};