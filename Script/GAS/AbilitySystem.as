struct FCalculationContainer
{
	TArray<UCalculation> Calculations;

	void Sort()
	{
		Calculations.Sort(true);
	}

	void AddCalculation(UCalculation Calculation)
	{
		if (!Calculations.Contains(Calculation))
		{
			Calculations.Add(Calculation);
		}
		else
		{
		}
	}

	void CalculateData(FAngelscriptGameplayAttributeData Data)
	{
		for (int i = 0; i < Calculations.Num(); i++)
		{
			Calculations[i].Calculate(Data.GetCurrentValue());
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

	private TMap<FName, FCalculationContainer> CalculationMap;

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
	void AddCalculation(FName AttrName, UCalculation Calculation)
	{
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
	private void SetValue(FName AttrName, float Value)
	{
		float32 NewValue = float32(Value);
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].DOnPreAttrChange.ExecuteIfBound(AttrName, NewValue);
			AttrSetContainer[i].SetCurrentValue(AttrName, NewValue);
			AttrSetContainer[i].DOnPostAttrChange.ExecuteIfBound(AttrName);
			EOnPostSetCurrentValue.Broadcast(AttrName, NewValue);
		}
	}

	UFUNCTION()
	void SetBaseValue(FName AttrName, float Value, bool bSetAsCurrent = false)
	{
		float32 NewValue = float32(Value);
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].DOnPreBaseAttrChange.ExecuteIfBound(AttrName, NewValue);
			AttrSetContainer[i].SetBaseValue(AttrName, NewValue);
			AttrSetContainer[i].DOnPostAttrChange.ExecuteIfBound(AttrName);
			EOnPostSetBaseValue.Broadcast(AttrName, NewValue);

			if (bSetAsCurrent)
			{
				AttrSetContainer[i].DOnPreAttrChange.ExecuteIfBound(AttrName, NewValue);
				AttrSetContainer[i].SetCurrentValue(AttrName, NewValue);
				AttrSetContainer[i].DOnPostAttrChange.ExecuteIfBound(AttrName);
				EOnPostSetCurrentValue.Broadcast(AttrName, NewValue);
			}
		}
	}

	UFUNCTION()
	float GetValue(FName AttrName)
	{
		FAngelscriptGameplayAttributeData Data;
		if (FindDataFromAllSets(AttrName, Data))
		{
			return Data.GetCurrentValue();
		}
		return -1000;
	}

	UFUNCTION()
	private float GetBaseValue(FName AttrName)
	{
		FAngelscriptGameplayAttributeData Data;
		if (FindDataFromAllSets(AttrName, Data))
		{
			return Data.GetBaseValue();
		}
		return -1000;
	}

	UFUNCTION()
	void Calculate(FName AttrName)
	{
		FAngelscriptGameplayAttributeData Data;
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			Data = AttrSetContainer[i].GetLiteAttr(AttrName);
			AttrSetContainer[i].DOnPreCalculation.ExecuteIfBound(Data);
			// Do Calculation
			FCalculationContainer Calculations = CalculationMap.FindOrAdd(AttrName);
			AttrSetContainer[i].DOnPostCalculation.ExecuteIfBound(Data);
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