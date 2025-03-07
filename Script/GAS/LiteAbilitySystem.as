namespace AbilitySystem
{
	const float32 INVALID_VALUE = -1000;
}

struct FModifierContainer
{
	TArray<UModifier> ModifiersArray;

	void Sort()
	{
		ModifiersArray.Sort(true);
	}

	void AddModifier(UModifier Modifier)
	{
		ModifiersArray.Add(Modifier);
		ModifiersArray.Sort();
	}

	void RemoveModifier(const UObject Object, int ID)
	{
		for (int i = 0; i < ModifiersArray.Num(); i++)
		{
			if (ModifiersArray[i].GetOuter() == Object && ModifiersArray[i].ID == ID)
			{
				ModifiersArray.RemoveAt(i);
				i--;
			}
		}
	}

	void CalculateData(const ULiteAbilitySystem AbilitySystem, FName AttrName, float32& Result)
	{
		for (int i = 0; i < ModifiersArray.Num(); i++)
		{
			ModifiersArray[i].Calculate(AbilitySystem, Result);
		}
	}

	bool IsEmpty()
	{
		return ModifiersArray.IsEmpty();
	}
}

class ULiteAbilitySystem : ULiteAbilitySystemComponent
{
	private FGameplayTagContainer ActorTags;
	private TMap<int, FGameplayTag> TempTags;
	private int CurrentTempKey = 0;

	FGTagContainerEvent EOnActorTagAdded;
	FGameplayTagEvent EOnActorTagRemoved;
	FNameFloatEvent EOnPostSetCurrentValue;
	FNameFloatEvent EOnPostCalculation;
	FNameFloatEvent EOnPostSetBaseValue;
	FNameFloatEvent EOnPostAddModifier;
	FNameFloatEvent EOnPostRemoveModifier;

	private TMap<FName, FModifierContainer> ModifiersMap;

	UFUNCTION()
	void AddGameplayTag(FGameplayTag Tag)
	{
		if (!ActorTags.HasTag(Tag))
		{
			// Already check for uniqueness above so just add fast
			ActorTags.AddTagFast(Tag);
			EOnActorTagAdded.Broadcast(Tag.GetSingleTagContainer());
		}
	}

	UFUNCTION()
	void AddGameplayTags(FGameplayTagContainer Tags)
	{
		ActorTags.AppendTags(Tags);
		EOnActorTagAdded.Broadcast(Tags);
	}

	UFUNCTION()
	void AddTempGameplayTags(FGameplayTagContainer Tags)
	{
		for (int i = 0; i < Tags.Num(); i++)
		{
			AddTempGameplayTag(Tags.GameplayTags[i]);
		}
	}

	UFUNCTION()
	int AddTempGameplayTag(FGameplayTag Tag)
	{
		if (!ActorTags.HasTag(Tag))
		{
			CurrentTempKey++;
			TempTags.Add(CurrentTempKey, Tag);
			EOnActorTagAdded.Broadcast(Tag.GetSingleTagContainer());
			return CurrentTempKey;
		}
		return -1;
	}

	UFUNCTION()
	void RemoveTempGameplayTag(int Key)
	{
		if (TempTags.Contains(Key))
		{
			EOnActorTagRemoved.Broadcast(TempTags[Key]);
			TempTags.Remove(Key);
		}
	}

	UFUNCTION()
	void RemoveGameplayTag(FGameplayTag Tag)
	{
		if (ActorTags.HasTag(Tag))
		{
			ActorTags.RemoveTag(Tag);
			EOnActorTagRemoved.Broadcast(Tag);
		}
	}

	UFUNCTION()
	bool HasTag(FGameplayTag Tag)
	{
		return GetCurrentActorTags().HasTag(Tag);
	}

	UFUNCTION()
	FGameplayTagContainer GetCurrentActorTags()
	{
		FGameplayTagContainer CurrentTags = ActorTags;
		TArray<FGameplayTag> TempTagsArray;
		TempTags.GetValues(TempTagsArray);
		if (TempTagsArray.Num() > 0)
		{
			for (int i = 0; i < TempTagsArray.Num(); i++)
			{
				if (!CurrentTags.HasTagExact(TempTagsArray[i]))
				{
					CurrentTags.AddTag(TempTagsArray[i]);
				}
			}
		}
		return CurrentTags;
	}

	UFUNCTION()
	bool CheckForConditionalTag(FGameplayTag TagToCheck)
	{
		// Hmm maybe check for tags in temp tags?
		return ActorTags.HasTag(TagToCheck);
	}

	UFUNCTION()
	FGameplayTagContainer Filter(FGameplayTagContainer Tags)
	{
		return ActorTags.Filter(Tags);
	}

	UFUNCTION()
	void SetAbilitiesActivatable(bool bActivatable)
	{
		// for (auto Ability : AbilityContainer)
		// {
		// }
	}

	UFUNCTION()
	void AddModifier(FName AttrName, UModifier Modifier, bool bRecalculation = true)
	{
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			ModifiersMap.FindOrAdd(AttrName).AddModifier(Modifier);
			if (bRecalculation)
			{
				float32 NewValue = AbilitySystem::INVALID_VALUE;
				AttrSetContainer[i].GetBaseValue(AttrName, NewValue);
				CalculateCurrent(AttrName, NewValue, i);
				EOnPostAddModifier.Broadcast(AttrName, NewValue);
			}
		}
	}

	UFUNCTION()
	void RemoveModifier(FName AttrName, const UObject Object, int ID)
	{
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			if (ModifiersMap.Contains(AttrName))
			{
				ModifiersMap.FindOrAdd(AttrName).RemoveModifier(Object, ID);
				float32 NewValue = AbilitySystem::INVALID_VALUE;
				AttrSetContainer[i].GetBaseValue(AttrName, NewValue);
				CalculateCurrent(AttrName, NewValue, i);
				EOnPostRemoveModifier.Broadcast(AttrName, NewValue);
			}
		}
	}

	UFUNCTION()
	void Initialize(FName AttrName, float Value)
	{
		float32 NewValue = float32(Value);
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].Initialize(AttrName, NewValue);
		}
	}

	UFUNCTION()
	private void SetValue(const FName AttrName, float32& NewValue, int i)
	{
		if (!AttrSetContainer[i].DOnPreAttrChange.ExecuteIfBound(AttrName, NewValue))
		{
			AttrSetContainer[i].SetCurrentValue(AttrName, NewValue);
			AttrSetContainer[i].DOnPostAttrChange.ExecuteIfBound(AttrName);
			EOnPostSetCurrentValue.Broadcast(AttrName, NewValue);
		}
	}

	UFUNCTION()
	void SetBaseValue(FName AttrName, float Value, bool bCalculateCurrent = true)
	{
		float32 NewBaseValue = float32(Value);
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			if (!AttrSetContainer[i].DOnPreBaseAttrChange.ExecuteIfBound(AttrName, NewBaseValue))
			{
				AttrSetContainer[i].SetBaseValue(AttrName, NewBaseValue);
				AttrSetContainer[i].DOnPostBaseAttrChange.ExecuteIfBound(AttrName);
				EOnPostSetBaseValue.Broadcast(AttrName, NewBaseValue);

				if (bCalculateCurrent)
				{
					CalculateCurrent(AttrName, NewBaseValue, i);
				}
			}
		}
	}

	UFUNCTION()
	float32 GetValue(FName AttrName, bool bForceRecalculation = false)
	{
		float32 Result = AbilitySystem::INVALID_VALUE;
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			if (bForceRecalculation)
			{
				AttrSetContainer[i].GetBaseValue(AttrName, Result);
				CalculateCurrent(AttrName, Result, i);
			}
			else
			{
				AttrSetContainer[i].GetCurrentValue(AttrName, Result);
			}
		}
		else
		{
			PrintWarning(AttrName + " is not a valid attribute for " + Owner.GetName());
		}
		return Result;
	}

	UFUNCTION()
	float32 GetPercentageDiff(FName AttrName)
	{
		float32 Result1 = AbilitySystem::INVALID_VALUE;
		float32 Result2 = AbilitySystem::INVALID_VALUE;
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].GetCurrentValue(AttrName, Result1);
			AttrSetContainer[i].GetBaseValue(AttrName, Result2);
		}
		if (Result1 == AbilitySystem::INVALID_VALUE || Result2 == AbilitySystem::INVALID_VALUE)
		{
			return AbilitySystem::INVALID_VALUE;
		}
		return Result1 / Result2;
	}

	UFUNCTION()
	float32 GetFlatDiff(FName AttrName)
	{
		float32 Result1 = AbilitySystem::INVALID_VALUE;
		float32 Result2 = AbilitySystem::INVALID_VALUE;
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].GetCurrentValue(AttrName, Result1);
			AttrSetContainer[i].GetBaseValue(AttrName, Result2);
		}
		if (Result1 == AbilitySystem::INVALID_VALUE || Result2 == AbilitySystem::INVALID_VALUE)
		{
			return AbilitySystem::INVALID_VALUE;
		}
		return Result1 - Result2;
	}

	UFUNCTION()
	private float32 GetBaseValue(FName AttrName)
	{
		float32 Result = AbilitySystem::INVALID_VALUE;
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].GetBaseValue(AttrName, Result);
		}
		return Result;
	}

	UFUNCTION()
	void CalculateCurrent(FName AttrName, float32& FinalValue, int i, bool bSetCurrent = true)
	{
		if (!AttrSetContainer[i].DOnPreCalculation.ExecuteIfBound(AttrName, FinalValue))
		{
			// Do Calculation
			FModifierContainer Modifiers = ModifiersMap.FindOrAdd(AttrName);
			if (!Modifiers.IsEmpty())
			{
				Modifiers.CalculateData(this, AttrName, FinalValue);
			}
			if (bSetCurrent)
			{
				SetValue(AttrName, FinalValue, i);
			}
			AttrSetContainer[i].DOnPostCalculation.ExecuteIfBound(AttrName);
			EOnPostCalculation.Broadcast(AttrName, FinalValue);
		}
	}

	UFUNCTION()
	void ImportData(TMap<FName, float32> Data)
	{
		int ImportCount = 0;
		for (int i = 0; i < AttrSetContainer.Num(); i++)
		{
			ImportCount += AttrSetContainer[i].ImportData(Data);
		}
		if (ImportCount != Data.Num())
		{
			PrintError("Import Error Count: " + (Data.Num() - ImportCount));
		}
	}

	//////////////////////////////////////////
	// Abilities
	//////////////////////////////////////////

	// UFUNCTION(BlueprintOverride)
	// ULiteAbilityBase PostRegisterAbility()
	// {
	// }
};