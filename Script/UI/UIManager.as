class AUIManager : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable KeywordDataTable;

	TMap<FGameplayTag, FName> KeywordMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FName> KeywordNames = KeywordDataTable.GetRowNames();
		for (FName KeyName : KeywordNames)
		{
			FKeywordDT KeywordRow;
			KeywordDataTable.FindRow(KeyName, KeywordRow);
			if (KeywordRow.KeywordTag.IsValid())
			{
				KeywordMap.Add(KeywordRow.KeywordTag, KeyName);
			}
		}
	}

	UFUNCTION()
	FName GetKeywordName(FGameplayTag KeywordTag)
	{
		FName Result;
		if (KeywordMap.Find(KeywordTag, Result))
		{
			return Result;
		}
		else
		{
			Print("GetKeywordName: " + KeywordTag.ToString() + " not found");
			return Result;
		}
	}

	// TSet<UUserWidget> Widgets;
	// FName LastAddedWidgetClass;

	// UFUNCTION()
	// void AddFocusWidget(UUserWidget WidgetClass)
	// {
	// 	Widgets.Add(WidgetClass);
	// 	LastAddedWidgetClass = WidgetClass.GetClass().GetSuperClass().GetName();
	// }

	// UFUNCTION()
	// void RemoveFocusWidget(UUserWidget WidgetClass)
	// {
	// 	Widgets.Remove(WidgetClass);
	// }

	// UFUNCTION()
	// bool CheckFocusOfClass(UClass iClass)
	// {
	// 	if (!LastAddedWidgetClass.IsNone() && LastAddedWidgetClass.IsEqual(iClass.Name))
	// 	{
	// 		LastAddedWidgetClass = n"";
	// 		return true;
	// 	}
	// 	LastAddedWidgetClass = n"";
	// 	return false;
	// }

	UFUNCTION()
	void CheckAndRemoveWidgetsOfClass(UClass iClass)
	{
		TArray<UUserWidget> WidgetsToRemove;
		Widget::GetAllWidgetsOfClass(WidgetsToRemove, iClass);
		for (UUserWidget Widget : WidgetsToRemove)
		{
			if (Widget.HasAnyUserFocus())
			{
				return;
			}
		}
		for (UUserWidget Widget : WidgetsToRemove)
		{
			Widget.RemoveFromParent();
		}
	}
};