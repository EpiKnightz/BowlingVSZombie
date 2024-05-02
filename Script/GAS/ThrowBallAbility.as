class UThrowBallAbility : UAngelscriptGASAbility
{
	UPROPERTY()
	TSubclassOf<UGameplayEffect> GameplayEffect;

	UFUNCTION(BlueprintOverride)
	void ActivateAbility()
	{
		if (CommitAbility())
		{
			// GetAvatarActorFromActorInfo();
			//  AngelscriptAbilityTask::PlayMontageAndWait();)

			ApplyGameplayEffectToOwner(GameplayEffect);
			// GetAbilitySystemComponentFromActorInfo().SendGameplayEvent();
		}
		else
		{
			EndAbility();
		}
	}

	UFUNCTION(BlueprintOverride)
	void OnEndAbility(bool bWasCancelled)
	{
		Print("End");
	}

	UFUNCTION(BlueprintOverride)
	bool CanActivateAbility(FGameplayAbilityActorInfo iActorInfo, FGameplayAbilitySpecHandle Handle,
							FGameplayTagContainer& RelevantTags) const
	{
		return true;
	}
};