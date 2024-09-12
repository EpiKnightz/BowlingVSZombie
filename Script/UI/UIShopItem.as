class UUIShopItem : UUserWidget
{
	UPROPERTY(BindWidget)
	UImage ItemImage;

	UPROPERTY(BindWidget)
	UCommonTextBlock ItemName;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock CostText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ChosenAnimation;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation PriceOutAnimation;

	FText ItemDesc;
	bool bIsBuyable = true;

	UFUNCTION()
	void SetItemData(FCardDT ItemData)
	{
		ItemImage.SetBrushFromTexture(ItemData.Icon);
		ItemName.SetText(FText::FromString(ItemData.Name));
		ItemDesc = ItemData.Description;
		CostText.SetCurrentValue(ItemData.Cost);
	}

	UFUNCTION()
	void ItemChosen(bool IsChosen)
	{
		if (IsChosen)
		{
			PlayAnimation(ChosenAnimation, 0, 0);
		}
		else
		{
			StopAnimation(ChosenAnimation);
		}
	}

	UFUNCTION()
	void OnCoinChanged(int NewCoinAmount)
	{
		if (bIsBuyable)
		{
			if (CostText.GetTargetValue() > NewCoinAmount)
			{
				PlayAnimation(PriceOutAnimation);
				bIsBuyable = false;
			}
		}
		else
		{
			if (CostText.GetTargetValue() <= NewCoinAmount)
			{
				PlayAnimation(PriceOutAnimation, 0, 1, EUMGSequencePlayMode::Reverse);
				bIsBuyable = true;
			}
		}
	}

	UFUNCTION()
	FText GetItemDesc()
	{
		return ItemDesc;
	}
}