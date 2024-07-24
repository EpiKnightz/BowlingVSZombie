class UUIMultiplierText : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonNumericTextBlock MultiplierText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation MultiplierChangeAnimation;

	UFUNCTION()
	void SetMultiplierCountText(float NewMultiplier)
	{
		MultiplierText.SetCurrentValue(NewMultiplier);
		if (NewMultiplier == 1)
		{
			MultiplierText.SetVisibility(ESlateVisibility::Visible);
			PlayAnimation(MultiplierChangeAnimation);
		}
	}
}