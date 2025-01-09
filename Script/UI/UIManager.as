class AUIManager : AActor
{
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