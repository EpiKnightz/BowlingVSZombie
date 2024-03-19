
class UUIZombieGameplay : UUserWidget
{
	UPROPERTY(BlueprintReadWrite)
	ABowlingPawn BowlingPawn;

	UPROPERTY(BlueprintReadWrite)
	AZombieManager ZombieManager;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock ProgressText;

	UPROPERTY(BindWidget)
	UCommonTextBlock WarningMsg;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation WarningAnim;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock ComboText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ComboAnim;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock CoinText;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation CoinAnim;

	UFUNCTION(BlueprintEvent)
	void UpdateLevelProgress(float NewProgress)
	{
		ProgressText.SetCurrentValue(NewProgress);
	}

	UFUNCTION(BlueprintEvent)
	void UpdateScore(int NewScore)
	{
		// To be implemented in Blueprint
	}

	UFUNCTION(BlueprintEvent)
	void UpdateHP(int NewHP)
	{
		// To be implemented in Blueprint
	}

	UFUNCTION(BlueprintEvent)
	void UpdateCombo(int NewValue)
	{
		// To be implemented in Blueprint
		if (NewValue > 0)
		{
			ComboText.SetCurrentValue(NewValue);
			PlayAnimation(ComboAnim);
		}
	}

	UFUNCTION(BlueprintEvent)
	void UpdateCoin(int NewValue)
	{
		if (NewValue > 0)
		{
			CoinText.SetCurrentValue(NewValue);
			PlayAnimation(CoinAnim);
		}
	}

	UFUNCTION(BlueprintEvent)
	void WinUI()
	{
		// To be implemented in Blueprint
	}

	UFUNCTION(BlueprintEvent)
	void LoseUI()
	{
		// To be implemented in Blueprint
	}

	UFUNCTION()
	void UpdateWarningText(FText NewWarningText)
	{
		if (!NewWarningText.IsEmpty())
		{
			WarningMsg.SetText(NewWarningText);
			SetVisibility(ESlateVisibility::SelfHitTestInvisible);
			PlayAnimation(WarningAnim);
		}
		else
		{
			SetVisibility(ESlateVisibility::Collapsed);
		}
	}

	UFUNCTION(BlueprintCallable)
	void OnNextLevelClicked()
	{
		Cast<ABowlingGameMode>(Gameplay::GetGameMode()).NextLevel();
	}
}
