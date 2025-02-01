class UUICard : UUserWidget
{
	// UPROPERTY(meta = (BindWidget))
	// UCommonTextBlock CardName;

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

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation IntroAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation StarIntroAnim1;

	UFUNCTION(BlueprintCallable)
	void SetCardData(FCardDT CardData)
	{
		// RewardName.SetText(FText::FromString(RewardData.Name));
		CardDescription.SetText(CardData.Description);
		SetStars(CardData.Star);
		// RewardIcon.SetBrushFromTexture(RewardData.Icon);
	}

	UFUNCTION(BlueprintCallable)
	void PlayIntroAnim()
	{
		PlayAnimation(IntroAnim);
		System::SetTimer(this, n"PlayCardIntroAnim", IntroAnim.GetEndTime() * Gameplay::GetGlobalTimeDilation(), false);
	}

	UFUNCTION(BlueprintCallable)
	void PlayCardIntroAnim()
	{
		PlayAnimation(StarIntroAnim1);
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