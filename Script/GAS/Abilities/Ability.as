class UAbility : ULiteAbilityBase
{
	// Requirements
	// - Attribute Cost
	// - Cooldown- Which could also be a attribute cost

	ULiteAbilitySystem AbilitySystem;

	FGameplayTag AbilityID;
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
		AbilityID = InAbilityID;
		AbilityData = AbilitiesManager.GetAbilityData(AbilityID);
		if (AbilityData.AbilityID.IsValid())
		{
			switch (AbilityData.TriggerType)
			{
				case EAbilityTriggerType::OnOverlap:
				{
					Trigger = NewObject(this, UTriggerOnOverlap);
					break;
				}
				case EAbilityTriggerType::OnTimeLoop:
				{
					Trigger = NewObject(this, UTriggerOnTimeLoop);
					break;
				}
				case EAbilityTriggerType::OnSetup:
				{
					Trigger = NewObject(this, UTriggerOnSetup);
					break;
				}
				case EAbilityTriggerType::OnOverlapMarkTarget:
				{
					Trigger = NewObject(this, UTriggerOnOverlapMarkTarget);
					break;
				}
				default:
				{
					Print("TriggerType not implemented");
					return false;
				}
			}
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