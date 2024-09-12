class UUIRankText : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonTextBlock RankText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation RankChangeAnimation;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation RankStopAnimation;

	UFUNCTION()
	void SetRankText(int NewRank)
	{
		RankText.SetText(FText::FromString("Rk." + NewRank));
		if (NewRank > 0 && !RankText.IsVisible())
		{
			RankText.SetVisibility(ESlateVisibility::Visible);
			PlayAnimation(RankChangeAnimation);
		}
		System::SetTimer(this, n"FadeRankText", 3, false);
	}

	UFUNCTION()
	private void FadeRankText()
	{
		if (RankText.IsVisible())
		{
			PlayAnimation(RankStopAnimation);
		}
	}
}