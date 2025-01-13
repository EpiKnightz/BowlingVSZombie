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

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation IntroAnim;

	FGameplayTag2FNameDelegate DGetNameFromTag;

	void Setup(float32 MouseX, float32 MouseY, int ViewportSizeX, int ViewportSizeY)
	{
		SetPositionInViewport(FVector2D(MouseX, MouseY));
		SetAlignmentInViewport(FVector2D(MouseX >= (ViewportSizeX / 2.0) ? 1 : 0,
										 MouseY >= (ViewportSizeY / 2.0) ? 1 : 0));
		PlayAnimation(IntroAnim);
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
		Description.SetText(AddExtraInfos(Keyword));
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

	FText AddExtraInfos(FStatusDT Keyword)
	{
		FString ResultString;
		FString KeyName = Keyword.Name.ToString();
		KeyName.RemoveSpacesInline();
		if (Keyword.Duration > 0)
		{
			ResultString += "Duration: <attr eff=\"" + KeyName + "\" id=\"Duration\"/>\n";
		}
		if (Keyword.StackingRule == EStackingRule::Stackable
			|| Keyword.StackingRule == EStackingRule::StackAndRefreshable)
		{
			ResultString += "Max Stack: <attr eff=\"" + KeyName + "\" id=\"Stack\"/>";
		}
		if (!ResultString.IsEmpty())
		{
			ResultString = "\n\n" + ResultString;
		}
		ResultString = Keyword.Description.ToString() + ResultString;
		return FText::FromString(ResultString);
	}

	UFUNCTION(BlueprintOverride)
	void OnRemovedFromFocusPath(FFocusEvent InFocusEvent)
	{
		RemoveFromParent();
	}
}