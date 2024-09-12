class UUIMultiplierText : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonNumericTextBlock MultiplierText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation MultiplierChangeAnimation;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation MultiplierStopAnimation;

	UFUNCTION()
	void SetMultiplierCountText(int NewMultiplier)
	{
		MultiplierText.SetCurrentValue(NewMultiplier);
		if (NewMultiplier > 0 && !MultiplierText.IsVisible())
		{
			MultiplierText.SetVisibility(ESlateVisibility::Visible);
			PlayAnimation(MultiplierChangeAnimation);
		}
		System::SetTimer(this, n"FadeMultiplierText", 1.5, false);
	}

	UFUNCTION()
	private void FadeMultiplierText()
	{
		if (MultiplierText.IsVisible())
		{
			PlayAnimation(MultiplierStopAnimation);
		}
	}
}