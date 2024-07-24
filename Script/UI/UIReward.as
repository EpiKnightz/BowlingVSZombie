class UUIReward : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonTextBlock RewardName;

	UPROPERTY(BindWidget)
	UImage RewardIcon;

	UPROPERTY(BindWidget)
	UCommonTextBlock RewardDescription;

	UFUNCTION()
	void SetRewardData(FCardDT RewardData)
	{
		RewardName.SetText(FText::FromString(RewardData.Name));
		RewardDescription.SetText(RewardData.Description);
		RewardIcon.SetBrushFromTexture(RewardData.Icon);
	}

	// UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	// UWidgetAnimation MultiplierChangeAnimation;
}
