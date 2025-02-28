class UAddEffectAbility : UAttackAbility
{
	UPROPERTY(BlueprintReadWrite)
	TArray<FGameplayTag> StatusEffectTags;

	private TArray<int> TempKeys;

	void ActivateAbilityChild(AActor Target) override
	{
		for (int i = 0; i < StatusEffectTags.Num(); i++)
		{
			int TagKey = AbilitySystem.AddTempGameplayTag(StatusEffectTags[i]);
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
			AbilitySystem.RemoveTempGameplayTag(TempKeys[i]);
		}
		Super::OnAbilityEnd();
	}
}