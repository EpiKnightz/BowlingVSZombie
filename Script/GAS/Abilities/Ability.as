class UAbility : ULiteAbilityBase
{
	UInteractSystem InteractSystem;

	UTrigger Trigger;

	protected AAbilitiesManager AbilitiesManager;
	protected FAbilityDT AbilityData;
	protected int Key;

	UFUNCTION(BlueprintOverride)
	void PostRegisterAbility(const ULiteAbilitySystemComponent iAbilitySystem, int iKey, FGameplayTag iAbilityTag)
	{
		Key = iKey;
		InteractSystem = Cast<UInteractSystem>(iAbilitySystem);
		if (IsValid(InteractSystem))
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
	void OnAbilityEnd()
	{
		if (AbilityData.AbilityTags.HasTagExact(GameplayTags::Description_Skill_Rage))
		{
			auto RageResponsePtr = URageResponseComponent::Get(InteractSystem.GetOwner());
			if (IsValid(RageResponsePtr))
			{
				RageResponsePtr.OnRageSkillEnd();
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	void RemoveAbility()
	{
		// Be careful with calling onabilityend here
		Trigger.StopTrigger();
		OnAbilityEnd();
		// InteractSystem.DeregAbility(Key);
	}
};