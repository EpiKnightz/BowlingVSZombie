class UUIHPBar : UUserWidget
{
	UPROPERTY(BindWidget)
	UProgressBar HPBar;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation FadeInAnimation;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation FadeOutAnimation;

	UFUNCTION()
	void SetHPBar(float Percent)
	{
		HPBar.SetPercent(Percent);
		if (Percent <= 0)
		{
			if (!IsAnimationPlaying(FadeOutAnimation))
			{
				FadeHPBar();
			}
		}
		else if (!HPBar.IsVisible())
		{
			StopAllAnimations();
			HPBar.SetVisibility(ESlateVisibility::Visible);
			PlayAnimation(FadeInAnimation);
		}
		System::SetTimer(this, n"FadeHPBar", 2.5, false);
	}

	UFUNCTION()
	private void FadeHPBar()
	{
		if (HPBar.IsVisible())
		{
			StopAllAnimations();
			PlayAnimation(FadeOutAnimation);
		}
	}
}