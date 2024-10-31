const int WISHING_COST_INCREASE = 100;

class UUIRest : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonNumericTextBlock InventoryCoinText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation CoinChangeAnim;

	UPROPERTY()
	int WishingCoinCost = 100;

	UPROPERTY()
	int RestoreHPAmountCost = 20;

	UPROPERTY()
	int RestoreHPPercentCost = 50;

	TArray<FCardDT> WishingPoolData;

	FFloatDelegate DRestoreRunHPPercent;
	FFloatDelegate DRestoreRunHPAmount;
	FCardDTDelegate DAddCardToInventory;
	FIntDelegate DChangeCoinTotal;
	FVoidDelegate DLeaveRest;

	UFUNCTION()
	void RestoreRunHPPercent(float HPPercent)
	{
		DRestoreRunHPPercent.ExecuteIfBound(HPPercent);
		DChangeCoinTotal.ExecuteIfBound(-RestoreHPPercentCost);
	}

	UFUNCTION()
	void RestoreRunHPAmount(float HPAmount)
	{
		DRestoreRunHPAmount.ExecuteIfBound(HPAmount);
		DChangeCoinTotal.ExecuteIfBound(-RestoreHPAmountCost);
	}

	UFUNCTION()
	void Wishing()
	{
		DChangeCoinTotal.ExecuteIfBound(-WishingCoinCost);
		DAddCardToInventory.ExecuteIfBound(WishingPoolData[Math::RandRange(0, WishingPoolData.Num() - 1)]);
		WishingCoinCost += WISHING_COST_INCREASE;
	}

	UFUNCTION()
	void Workshop()
	{
	}

	UFUNCTION()
	void SetWishingPoolData(TArray<FCardDT> Data)
	{
		WishingPoolData = Data;
	}

	UFUNCTION()
	void InterpolateCoinChanges(int Coins)
	{
		InventoryCoinText.InterpolateToValue(Coins, 0.25);
		PlayAnimation(CoinChangeAnim);
	}

	UFUNCTION()
	void SetInventoryCoin(int Coins)
	{
		InventoryCoinText.SetCurrentValue(Coins);
	}

	UFUNCTION()
	void OnLeaveRest()
	{
		DLeaveRest.ExecuteIfBound();
	}
}