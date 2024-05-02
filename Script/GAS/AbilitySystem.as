class UAbilitySystem : ULiteAbilitySystemComponent
{
	private FGameplayTagContainer ActorTags;

	FVoidEvent EOnActorTagAdded;
	FVoidEvent EOnActorTagRemoved;
	FNameFloatEvent EOnPostSetCurrentValue;
	FNameFloatEvent EOnPostSetBaseValue;

	// private TArray<TSubclassOf<ULiteAttrSet>> AttributeSetContainer;

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
	void SetCurrentValue(FName AttrName, float Value)
	{
		float32 NewValue = float32(Value);
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].PreAttrChange(AttrName, NewValue);
			AttrSetContainer[i].SetCurrentValue(AttrName, NewValue);
			AttrSetContainer[i].PostAttrChange(AttrName);
			EOnPostSetCurrentValue.Broadcast(AttrName, NewValue);
		}
	}

	UFUNCTION()
	void SetBaseValue(FName AttrName, float Value)
	{
		float32 NewValue = float32(Value);
		int i = GetSetIdx(AttrName);
		if (i >= 0)
		{
			AttrSetContainer[i].PreBaseAttrChange(AttrName, NewValue);
			AttrSetContainer[i].SetBaseValue(AttrName, NewValue);
			AttrSetContainer[i].PostAttrChange(AttrName);
			EOnPostSetBaseValue.Broadcast(AttrName, NewValue);
		}
	}

	UFUNCTION()
	float GetCurrentValue(FName AttrName)
	{
		FAngelscriptGameplayAttributeData Data;
		if (FindDataFromAllSets(AttrName, Data))
		{
			return Data.GetCurrentValue();
		}
		return -1000;
	}

	UFUNCTION()
	float GetBaseValue(FName AttrName)
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
			AttrSetContainer[i].PreCalculation(Data);
			// Do Calculation
			AttrSetContainer[i].PostCalculation(Data);
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