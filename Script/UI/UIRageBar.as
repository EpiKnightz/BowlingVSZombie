class UUIRageBar : UUserWidget
{
	UPROPERTY(BindWidget)
	UProgressBar RageBar;

	UPROPERTY(Transient, meta = (BindWidgetAnim))
	UWidgetAnimation FadeInAnimation;

	UFUNCTION()
	void SetRageBar(float Percent)
	{
		RageBar.SetPercent(Percent);
	}

	UFUNCTION()
	void HighlightRageBarAnim()
	{
		StopAllAnimations();
		PlayAnimation(FadeInAnimation);
	}
}