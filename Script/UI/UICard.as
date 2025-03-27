class UUICard : UUserWidget
{
	UPROPERTY(meta = (BindWidget))
	UCommonRichTextBlock CardName;
	UPROPERTY(meta = (BindWidget))
	UCommonRichTextBlock CardDescription;

	UPROPERTY(meta = (BindWidget))
	UImage Star_0;
	UPROPERTY(meta = (BindWidget))
	UImage Star_1;
	UPROPERTY(meta = (BindWidget))
	UImage Star_2;
	UPROPERTY(meta = (BindWidget))
	UImage Star_3;
	UPROPERTY(meta = (BindWidget))
	UImage Star_4;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor SilverColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor GoldColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor EpicColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor MythicColor;
	UPROPERTY(BlueprintReadOnly, Category = Rarity)
	FLinearColor CurrentColor = FLinearColor::White;

	UPROPERTY(meta = (BindWidget))
	UImage StruckTypeIcon;
	FName StruckTypeName;
	UPROPERTY(meta = (BindWidget))
	UImage ClassIcon;
	FName ClassName;
	UPROPERTY(meta = (BindWidget))
	UImage ElementIcon;
	FName ElementName;

	UPROPERTY(meta = (BindWidget))
	UImage ATKIcon;
	UPROPERTY(meta = (BindWidget))
	UImage HPIcon;
	UPROPERTY(meta = (BindWidget))
	UImage RAGEIcon;
	UPROPERTY(meta = (BindWidget))
	UCommonNumericTextBlock TextHP;
	UPROPERTY(meta = (BindWidget))
	UCommonNumericTextBlock TextATK;
	UPROPERTY(meta = (BindWidget))
	UCommonNumericTextBlock TextRAGE;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation IntroAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation StarIntroAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation StarIdleAnim;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable KeywordDataTable;

	FTag2AbilityDataDelegate DGetAbilityDataFromTag;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIKeywordDescription> KeywordPopup;

	UFUNCTION(BlueprintCallable)
	void SetCardData(FCardDT CardData)
	{
		CardName.SetText(FText::FromString(CardData.Name));
		// CardDescription.SetText(CardData.Description);
		SetStars(CardData.Star);

		//////////////////////////////////////////////////////////////////////////
		FGameplayTagContainer FilteredTags = CardData.DescriptionTags.Filter(GameplayTags::Description_StruckType.GetSingleTagContainer());
		SetIconFromTag(FilteredTags, StruckTypeIcon, StruckTypeName, n"OnStruckTypeClicked");

		FilteredTags = CardData.DescriptionTags.Filter(GameplayTags::Description_Class.GetSingleTagContainer());
		SetIconFromTag(FilteredTags, ClassIcon, ClassName, n"OnClassClicked");

		FilteredTags = CardData.DescriptionTags.Filter(GameplayTags::Description_Element.GetSingleTagContainer());
		SetIconFromTag(FilteredTags, ElementIcon, ElementName, n"OnElementClicked");

		FilteredTags = CardData.DescriptionTags.Filter(GameplayTags::Description_Misc_AtkRate.GetSingleTagContainer());
		ATKIcon.OnMouseButtonDownEvent.BindUFunction(this, n"OnATKClicked");

		FilteredTags = CardData.DescriptionTags.Filter(GameplayTags::Description_Misc_HP.GetSingleTagContainer());
		HPIcon.OnMouseButtonDownEvent.BindUFunction(this, n"OnHPClicked");

		FilteredTags = CardData.DescriptionTags.Filter(GameplayTags::Description_Misc_RageRegen.GetSingleTagContainer());
		RAGEIcon.OnMouseButtonDownEvent.BindUFunction(this, n"OnRAGEClicked");

		CurrentColor = FLinearColor::Gray;
	}

	FString GenDescFromTags(FGameplayTagContainer AbilitiesTags)
	{
		FString Result;
		TArray<FGameplayTag> TagsArray;
		GameplayTag::BreakGameplayTagContainer(AbilitiesTags, TagsArray);
		for (FGameplayTag Tag : TagsArray)
		{
			FAbilityDT AbilityData = DGetAbilityDataFromTag.Execute(Tag);
			if (AbilityData.AbilityID.IsValid())
			{
				if (!AbilityData.TriggerClass.Get().IsChildOf(UTriggerOnAttackCooldown))
				{
					FString AbilityKey = AbilityData.Name;
					AbilityKey.RemoveSpacesInline();
					Result += "<link id=\"" + AbilityKey + "\"/>\n ";
					Result += AbilityData.Description.ToString();
				}
			}
		}

		return Result;
	}

	UFUNCTION()
	void SetSurvivorData(FSurvivorDT SurvivorData)
	{
		TextHP.GetParent().SetVisibility(ESlateVisibility::Visible);
		TextHP.SetCurrentValue(SurvivorData.HP);
		TextRAGE.GetParent().SetVisibility(ESlateVisibility::Visible);
		TextRAGE.SetCurrentValue(SurvivorData.RageRegen + SurvivorData.RageBonus / 1.5);
		if (CardDescription.Text.IsEmptyOrWhitespace())
		{
			CardDescription.SetText(FText::FromString(GenDescFromTags(SurvivorData.AbilitiesTags) + "\n\n <span style=\"Italic\">"
													  + SurvivorData.Description.ToString() + "</>"));
		}
	}

	UFUNCTION()
	void SetWeaponData(FWeaponDT WeaponData, float AttackCooldown = 1)
	{
		TextATK.GetParent().SetVisibility(ESlateVisibility::Visible);
		TextATK.SetCurrentValue(WeaponData.Attack * WeaponData.AttackRating / AttackCooldown);
		if (CardDescription.Text.IsEmptyOrWhitespace())
		{
			CardDescription.SetText(FText::FromString(GenDescFromTags(WeaponData.WeaponAbilities)));
		}
	}

	void SetIconFromTag(FGameplayTagContainer FilteredTags, UImage& Icon, FName& IconTagName, FName ClickEventName)
	{
		if (!FilteredTags.IsEmpty())
		{
			IconTagName = FilteredTags.First().GetCurrentNameOnly();
			FKeywordDT KeywordRow;
			if (KeywordDataTable.FindRow(IconTagName, KeywordRow))
			{
				Icon.SetBrushFromTexture(KeywordRow.Icon);
				Icon.SetVisibility(ESlateVisibility::Visible);
				Icon.OnMouseButtonDownEvent.BindUFunction(this, ClickEventName);
				return;
			}
		}
		Icon.SetVisibility(ESlateVisibility::Collapsed);
	}

	UFUNCTION()
	private FEventReply OnStruckTypeClicked(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		return OnClicked(StruckTypeName);
	}

	UFUNCTION()
	private FEventReply OnClassClicked(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		return OnClicked(ClassName);
	}

	UFUNCTION()
	private FEventReply OnElementClicked(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		return OnClicked(ElementName);
	}

	UFUNCTION()
	private FEventReply OnATKClicked(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		return OnClicked(n"AttackRating");
	}

	UFUNCTION()
	private FEventReply OnHPClicked(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		return OnClicked(n"HealthPoint");
	}

	UFUNCTION()
	private FEventReply OnRAGEClicked(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		return OnClicked(RageAttrSet::RageRegen);
	}

	private FEventReply OnClicked(FName KeywordName)
	{
		if (KeywordName.IsNone())
		{
			PrintError("Keyword name is none");
			return FEventReply::Unhandled();
		}
		FKeywordDT KeywordRow;
		if (KeywordDataTable.FindRow(KeywordName, KeywordRow))
		{
			if (!KeywordRow.Description.IsEmptyOrWhitespace())
			{
				APlayerController PlayerController = Gameplay::GetPlayerController(0);
				auto UserWidget = Cast<UUIKeywordDescription>(WidgetBlueprint::CreateWidget(KeywordPopup, PlayerController));
				FVector2D MousePos = WidgetLayout::GetMousePositionOnViewport() * WidgetLayout::GetViewportScale();
				FVector2D ViewportSize = WidgetLayout::GetViewportSize();
				UserWidget.Setup();
				UserWidget.SetKeywordDescription(KeywordRow);
				UserWidget.AddToViewport();
				UserWidget.SetFocus();
			}
		}
		else
		{
			PrintError("Keyword not found: " + KeywordName);
			return FEventReply::Unhandled();
		}
		return FEventReply::Handled();
	}

	UFUNCTION(BlueprintCallable)
	void PlayIntroAnim()
	{
		PlayAnimation(IntroAnim);
		System::SetTimer(this, n"PlayStarIntroAnim", IntroAnim.GetEndTime() * Gameplay::GetGlobalTimeDilation(), false);
	}

	UFUNCTION(BlueprintCallable)
	void PlayStarIntroAnim()
	{
		PlayAnimation(StarIntroAnim);
		// System::SetTimer(this, n"PlayStarIdleAnim", StarIntroAnim.GetEndTime() * Gameplay::GetGlobalTimeDilation(), false);
	}

	UFUNCTION(BlueprintCallable)
	void PlayStarIdleAnim()
	{
		PlayAnimation(StarIdleAnim, 0, 0, EUMGSequencePlayMode::Forward, 0.5);
	}

	UFUNCTION(BlueprintCallable)
	void SetStars(int Stars)
	{
		Star_0.SetVisibility(Stars > 0 ? ESlateVisibility::Visible : ESlateVisibility::Collapsed);
		Star_1.SetVisibility(Stars > 1 ? ESlateVisibility::Visible : ESlateVisibility::Collapsed);
		Star_2.SetVisibility(Stars > 2 ? ESlateVisibility::Visible : ESlateVisibility::Collapsed);
		Star_3.SetVisibility(Stars > 3 ? ESlateVisibility::Visible : ESlateVisibility::Collapsed);
		Star_4.SetVisibility(Stars > 4 ? ESlateVisibility::Visible : ESlateVisibility::Collapsed);
	}
}