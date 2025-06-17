class UAddEffectAbility : UAttackAbility
{
	// UPROPERTY(BlueprintReadWrite)

	private TArray<int> TempKeys;

	void ActivateAbilityChild(AActor Target) override
	{
		TArray<FGameplayTag> StatusEffectTags;
		AbilityData.AbilityParams.GetKeys(StatusEffectTags);
		for (int i = 0; i < StatusEffectTags.Num(); i++)
		{
			int TagKey = InteractSystem.AddTempGameplayTag(StatusEffectTags[i]);
			if (TagKey != -1)
			{
				TempKeys.Add(TagKey);
			}
		}
	}

	void OnAbilityEnd() override
	{
		for (int i = 0; i < TempKeys.Num(); i++)
		{
			InteractSystem.RemoveTempGameplayTag(TempKeys[i]);
		}
		Super::OnAbilityEnd();
	}
}