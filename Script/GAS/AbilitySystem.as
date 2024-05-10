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
			}
		}
	}

	void CalculateData(const UAbilitySystem AbilitySystem, FName AttrName, float32& Result)
	{
		for (int i = 0; i < ModifiersArray.Num(); i++)
		{
			ModifiersArray[i].Calculate(AbilitySystem, Result);
		}
	}
}

class UAbilitySystem : ULiteAbilitySystemComponent
{
	private FGameplayTagContainer ActorTags;

	FVoidEvent EOnActorTagAdded;
	FVoidEvent EOnActorTagRemoved;
	FNameFloatEvent EOnPostSetCurrentValue;
	FNameFloatEvent EOnPostSetBaseValue;

	private TMap<FName, FModifierContainer> ModifiersMap;

	UFUNCTION()
	void AddGameplayTag(FGameplayTag Tag)
	{
		if (!ActorTags.HasTag(Tag))
		{
			// Already check for uniqueness above so just add fast
			ActorTags.AddTagFast(Tag);
			EOnActorTagAdded.Broadcast();
		}
	}

	UFUNCTION()
	void RemoveGameplayTag(FGameplayTag Tag)
	{
		if (ActorTags.HasTag(Tag))
		{
			ActorTags.RemoveTag(Tag);
			EOnActorTagRemoved.Broadcast();
		}
	}

	UFUNCTION()
	bool CheckForConditionalTag(FGameplayTag TagToCheck)
	{
		return ActorTags.HasTag(TagToCheck);
	}

	UFUNCTION()
	void AddModifier(FName AttrName, UModifier Modifier)
	{
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			ModifiersMap.FindOrAdd(AttrName).AddModifier(Modifier);
			float32 NewValue;
			AttrSetContainer[i].GetBaseValue(AttrName, NewValue);
			Calculate(AttrName, NewValue, i);
			SetValue(AttrName, NewValue, i);
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
				float32 NewValue;
				AttrSetContainer[i].GetBaseValue(AttrName, NewValue);
				Calculate(AttrName, NewValue, i);
				SetValue(AttrName, NewValue, i);
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
	void SetBaseValue(FName AttrName, float Value, bool bCalculateCurrent = true, bool bForceSaveAsCurrent = false)
	{
		float32 NewBaseValue = float32(Value);
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			if (!AttrSetContainer[i].DOnPreBaseAttrChange.ExecuteIfBound(AttrName, NewBaseValue))
			{
				AttrSetContainer[i].SetBaseValue(AttrName, NewBaseValue);
				AttrSetContainer[i].DOnPostAttrChange.ExecuteIfBound(AttrName);
				EOnPostSetBaseValue.Broadcast(AttrName, NewBaseValue);

				if (bCalculateCurrent)
				{
					float32 NewValue = NewBaseValue;
					if (!bForceSaveAsCurrent)
					{
						Calculate(AttrName, NewValue, i);
					}
					SetValue(AttrName, NewValue, i);
				}
			}
		}
	}

	UFUNCTION()
	float GetValue(FName AttrName, bool bForceRecalculation = false)
	{
		float32 Result = -1000;
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			if (bForceRecalculation)
			{
				AttrSetContainer[i].GetBaseValue(AttrName, Result);
				Calculate(AttrName, Result, i);
				SetValue(AttrName, Result, i);
			}
			else
			{
				AttrSetContainer[i].GetCurrentValue(AttrName, Result);
			}
		}
		return Result;
	}

	UFUNCTION()
	private float GetBaseValue(FName AttrName)
	{
		float32 Result = -1000;
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].GetBaseValue(AttrName, Result);
		}
		return Result;
	}

	UFUNCTION()
	void Calculate(FName AttrName, float32& FinalValue, int i)
	{
		if (!AttrSetContainer[i].DOnPreCalculation.ExecuteIfBound(AttrName))
		{
			// Do Calculation
			FModifierContainer Modifiers = ModifiersMap.FindOrAdd(AttrName);
			Modifiers.CalculateData(this, AttrName, FinalValue);
			AttrSetContainer[i].DOnPostCalculation.ExecuteIfBound(AttrName);
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
};