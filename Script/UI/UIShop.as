const int SHOP_SIZE = 4;

class UUIShop : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonRichTextBlock DescTextBox;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock InventoryCoinText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation CoinChangeAnim;

	TArray<UUIShopItem> ShopItems;
	TArray<FCardDT> ShopData;
	int CurrentIndex = 0;
	int CurrentMapPosition = -1;

	FCardDTEvent EOnShopItemBought;
	FIntDelegate DLeaveShop;
	FIntEvent EOnCoinChanged;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		TArray<UWidget> WidgetList;
		GetAllWidgets(WidgetList);
		for (int i = 0; i < WidgetList.Num(); i++)
		{
			UUIShopItem Item = Cast<UUIShopItem>(WidgetList[i]);
			if (IsValid(Item))
			{
				ShopItems.Add(Item);
			}
		}
	}

	UFUNCTION()
	void OnLeaveShop()
	{
		DLeaveShop.ExecuteIfBound(CurrentMapPosition);
	}

	UFUNCTION()
	void BuyCurrentItem()
	{
		if (CurrentIndex > -1)
		{
			if (ShopItems[CurrentIndex].bIsBuyable)
			{
				ShopItems[CurrentIndex].SetVisibility(ESlateVisibility::Hidden);
				EOnShopItemBought.Broadcast(ShopData[CurrentIndex]);
				CurrentIndex = -1;
			}
			else
			{
				Print("Not enough coins");
			}
		}
	}

	UFUNCTION()
	void ItemChosen(int Idx)
	{
		if (CurrentIndex != -1)
		{
			ShopItems[CurrentIndex].ItemChosen(false);
		}
		CurrentIndex = Idx;
		DescTextBox.SetText(ShopItems[CurrentIndex].GetItemDesc());
		ShopItems[CurrentIndex].ItemChosen(true);
	}

	UFUNCTION(BlueprintCallable)
	void SetShopData(TArray<FCardDT> ItemsData)
	{
		ShopData = ItemsData;
		// Randomly remove items until we have the right amount
		while (ShopData.Num() > SHOP_SIZE)
		{
			ShopData.RemoveAt(Math::RandRange(0, ShopData.Num() - 1));
		}
		for (int i = 0; i < SHOP_SIZE; i++)
		{
			ShopItems[i].SetItemData(ShopData[i]);
			EOnCoinChanged.AddUFunction(ShopItems[i], n"OnCoinChanged");
		}
		ItemChosen(0);
	}

	UFUNCTION()
	void InterpolateCoinChanges(int Coins)
	{
		InventoryCoinText.InterpolateToValue(Coins, 0.25);
		PlayAnimation(CoinChangeAnim);
		EOnCoinChanged.Broadcast(Coins);
	}

	UFUNCTION()
	void SetInventoryCoin(int Coins)
	{
		InventoryCoinText.SetCurrentValue(Coins);
		EOnCoinChanged.Broadcast(Coins);
	}
}