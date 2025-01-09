class UUIKeywordDescription : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonTextBlock KeywordName;

	UPROPERTY(BindWidget)
	UCommonRichTextBlock Description;

	UPROPERTY(BindWidget)
	UImage Icon;

	int ZOrder = 0;

	// FClassDelegate DCheckAndRemoveWidgetsOfClass;
	//  FClass2BoolDelegate DCheckFocusOfClass;
	//  FWidgetDelegate DAddFocusWidget;
	//  FWidgetDelegate DRemoveFocusWidget;

	UFUNCTION()
	void SetKeywordDescription(FKeywordDT Keyword)
	{
		KeywordName.SetText(Keyword.Name);
		Description.SetText(Keyword.Description);
		if (IsValid(Keyword.Icon))
		{
			Icon.SetVisibility(ESlateVisibility::Visible);
			Icon.SetBrushFromTexture(Keyword.Icon);
		}
		else
		{
			Icon.SetVisibility(ESlateVisibility::Hidden);
		}
	}

	UFUNCTION()
	void SetEffectDescription(FStatusDT Keyword)
	{
		KeywordName.SetText(Keyword.Name);
		Description.SetText(FText::Format(Keyword.Description, 0));
		if (IsValid(Keyword.Icon))
		{
			Icon.SetVisibility(ESlateVisibility::Visible);
			Icon.SetBrushFromTexture(Keyword.Icon);
		}
		else
		{
			Icon.SetVisibility(ESlateVisibility::Hidden);
		}
	}

	// UFUNCTION(BlueprintOverride)
	// void OnAddedToFocusPath(FFocusEvent InFocusEvent)
	// {
	// 	Print("OnAddedToFocusPath");
	// 	DAddFocusWidget.ExecuteIfBound(this);
	// }

	UFUNCTION(BlueprintOverride)
	void OnFocusLost(FFocusEvent InFocusEvent)
	{
		// FLatentActionInfo LatentInfo;
		// LatentInfo.CallbackTarget = this;
		// LatentInfo.ExecutionFunction = n"CheckAndRemoveFromViewPort";
		// LatentInfo.Linkage = 0;
		// LatentInfo.UUID = 1;

		// System::Delay(0.1, LatentInfo);
		// if (!Icon.IsVisible())
		//{
		// RemoveFromParent();
		//}
	}

	// UFUNCTION()
	// void CheckAndRemoveFromViewPort()
	// {
	// 	DCheckAndRemoveWidgetsOfClass.ExecuteIfBound(UUIKeywordDescription);
	// }

	// UFUNCTION(BlueprintOverride)
	// FEventReply OnFocusReceived(FGeometry MyGeometry, FFocusEvent InFocusEvent)
	// {
	// 	SetViewportOrder(ZOrder);
	// 	ZOrder++;
	// 	return FEventReply();
	// }

	UFUNCTION(BlueprintOverride)
	void OnRemovedFromFocusPath(FFocusEvent InFocusEvent)
	{
		// Print("OnRemovedFromFocusPath");
		RemoveFromParent();
	}

	// UFUNCTION(BlueprintOverride)
	// FEventReply OnMouseButtonUp(FGeometry MyGeometry, FPointerEvent MouseEvent)
	// {
	// 	Print("OnMouseButtonUp");
	// 	return FEventReply();
	// }
}