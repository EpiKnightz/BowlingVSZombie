
class UUIZombieGameplay : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonNumericTextBlock ProgressText;

	UPROPERTY(BindWidget)
	UCommonTextBlock WarningMsg;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation WarningAnim;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock ComboText;

	UPROPERTY(BindWidget)
	UUIReward RewardUI;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ComboAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ComboHighAnim;

	// UPROPERTY(BindWidget)
	// UCommonNumericTextBlock CoinText;

	// UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	// UWidgetAnimation CoinAnim;

	UPROPERTY(BindWidget)
	USlider LevelProgress;

	UPROPERTY(BindWidget)
	UProgressBar CooldownBar;

	UFUNCTION(BlueprintEvent)
	void UpdateLevelProgress(float NewProgress)
	{
		ProgressText.SetCurrentValue(NewProgress);
		LevelProgress.SetValue(NewProgress);
	}

	UFUNCTION(BlueprintEvent)
	void UpdateCooldownPercent(float NewPercent){
		CooldownBar.SetPercent(NewPercent);
	}

	UFUNCTION(BlueprintEvent)
	void UpdateScore(int NewScore)
	{
		// To be implemented in Blueprint
	}

	UFUNCTION(BlueprintEvent)
	void UpdateHP(float NewHP)
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

			if (NewValue < 10)
			{
				PlayAnimation(ComboAnim);
			}
			else
			{
				if (NewValue == 10)
				{
					StopAnimation(ComboAnim);
				}
				PlayAnimation(ComboHighAnim);
			}
		}
	}

	UFUNCTION(BlueprintEvent)
	void UpdateCoin(int NewValue)
	{
		if (NewValue > 0)
		{
			// CoinText.SetCurrentValue(NewValue);
			// PlayAnimation(CoinAnim);
		}
	}

	UFUNCTION(BlueprintEvent)
	void WinUI(FCardDT RewardData)
	{
		//  To be implemented in Blueprint
	}

	UFUNCTION(BlueprintEvent)
	void LoseUI()
	{
		//  To be implemented in Blueprint
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
