class UAbility : ULiteAbilityBase
{
	ULiteAbilitySystem AbilitySystem;

	UTrigger Trigger;
	FGameplayTagContainer AbilityTags; // Like having status effect chill, pierce, etc

	protected AAbilitiesManager AbilitiesManager;
	protected FAbilityDT AbilityData;
	protected int Key;

	UFUNCTION(BlueprintOverride)
	void PostRegisterAbility(const ULiteAbilitySystemComponent iAbilitySystem, int iKey, FGameplayTag iAbilityTag)
	{
		Key = iKey;
		AbilitySystem = Cast<ULiteAbilitySystem>(iAbilitySystem);
		if (IsValid(AbilitySystem))
		{
			AbilitiesManager = Gameplay::GetActorOfClass(AAbilitiesManager);
			if (IsValid(AbilitiesManager))
			{
				if (GetAbilityData(iAbilityTag))
				{
					if (Trigger.SetupTrigger(this, AbilityData.TriggerParam) && SetupAbilityChild())
					{
						return;
					}
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
	bool GetAbilityData(FGameplayTag InAbilityID)
	{
		AbilityData = AbilitiesManager.GetAbilityData(InAbilityID);
		if (AbilityData.AbilityID.IsValid() && AbilityData.TriggerClass.IsValid())
		{
			Trigger = NewObject(this, AbilityData.TriggerClass);
			return true;
		}
		return false;
	}

	UFUNCTION()
	bool SetupAbilityChild()
	{
		return true;
	}

	UFUNCTION()
	void ActivateAbility(AActor Target)
	{
		if (Trigger.CanActivate(Target))
		{
			ActivateAbilityChild(Target);
		}
	}

	protected void ActivateAbilityChild(AActor Target)
	{
	}

	UFUNCTION()
	void StopAbility()
	{
	}

	UFUNCTION()
	void RemoveAbility()
	{
		StopAbility();
		Trigger.StopTrigger();
		AbilitySystem.DeregAbility(Key);
	}
};