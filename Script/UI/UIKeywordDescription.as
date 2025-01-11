class UUIKeywordDescription : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonTextBlock KeywordName;

	UPROPERTY(BindWidget)
	UCommonRichTextBlock Description;

	UPROPERTY(BindWidget)
	UCommonRichTextBlock Keytag;

	UPROPERTY(BindWidget)
	UImage Icon;

	FGameplayTag2FNameDelegate DGetNameFromTag;

	// int ZOrder = 0;

	// FClassDelegate DCheckAndRemoveWidgetsOfClass;
	//  FClass2BoolDelegate DCheckFocusOfClass;
	//  FWidgetDelegate DAddFocusWidget;
	//  FWidgetDelegate DRemoveFocusWidget;

	void Setup(float32 MouseX, float32 MouseY, int ViewportSizeX, int ViewportSizeY)
	{
		// SetDesiredSizeInViewport(FVector2D(400, 350));
		SetPositionInViewport(FVector2D(MouseX, MouseY));
		SetAlignmentInViewport(FVector2D(MouseX >= (ViewportSizeX / 2.0) ? 1 : 0,
										 MouseY >= (ViewportSizeY / 2.0) ? 1 : 0));
	}

	UFUNCTION()
	void SetKeywordDescription(FKeywordDT Keyword)
	{
		KeywordName.SetText(Keyword.Name);
		Description.SetText(Keyword.Description);
		Keytag.SetText(FText());
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
	FText EffectToTag(FStatusDT Keyword)
	{
		FString ResultString;
		switch (Keyword.StackingRule)
		{
			case EStackingRule::Stackable:
			{
				ResultString += MakeTag("Stackable");
				break;
			}
			case EStackingRule::Refreshable:
			{
				ResultString += MakeTag("Refreshable");
				break;
			}
			case EStackingRule::StackAndRefreshable:
			{
				ResultString += MakeTag("Stackable");
				ResultString += MakeTag("Refreshable");
				break;
			}
			default:
				break;
		}
		for (auto Tag : Keyword.DescriptionTags.GameplayTags)
		{
			ResultString += MakeTag(DGetNameFromTag.ExecuteIfBound(Tag).ToString());
		}
		ResultString.RemoveFromEnd(".");
		return FText::FromString(ResultString);
	}

	UFUNCTION()
	FString MakeTag(FString KeywordIn)
	{
		if (KeywordIn.IsEmpty() || KeywordIn == n"None")
		{
			return "";
		}
		else
		{
			return "<link id=\"" + KeywordIn + "\"/>.";
		}
	}

	UFUNCTION()
	void SetEffectDescription(FStatusDT Keyword)
	{
		KeywordName.SetText(Keyword.Name);
		Description.SetText(FText::Format(Keyword.Description, 0));
		Keytag.SetText(EffectToTag(Keyword));
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

	// UFUNCTION(BlueprintOverride)
	// void OnFocusLost(FFocusEvent InFocusEvent)
	// {
	// 	FLatentActionInfo LatentInfo;
	// 	LatentInfo.CallbackTarget = this;
	// 	LatentInfo.ExecutionFunction = n"CheckAndRemoveFromViewPort";
	// 	LatentInfo.Linkage = 0;
	// 	LatentInfo.UUID = 1;

	// 	System::Delay(0.1, LatentInfo);
	// 	if (!Icon.IsVisible())
	// 	{
	// 	RemoveFromParent();
	// 	}
	// }

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