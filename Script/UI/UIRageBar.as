class UUIRageBar : UUserWidget
{
	UPROPERTY(BindWidget)
	UProgressBar RageBar;

	UFUNCTION()
	void SetRageBar(float Percent)
	{
		RageBar.SetPercent(Percent);
	}
}