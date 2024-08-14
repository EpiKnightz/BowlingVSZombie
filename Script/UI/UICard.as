class UUICard : UUserWidget
{
	// UPROPERTY(meta = (BindWidget))
	// UCommonTextBlock CardName;

	UPROPERTY(meta = (BindWidget))
	UCommonTextBlock CardDescription;

	UFUNCTION(BlueprintCallable)
	void SetCardData(FCardDT CardData)
	{
		// RewardName.SetText(FText::FromString(RewardData.Name));
		CardDescription.SetText(CardData.Description);
		// RewardIcon.SetBrushFromTexture(RewardData.Icon);
	}
}