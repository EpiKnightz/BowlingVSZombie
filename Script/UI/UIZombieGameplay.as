
const int LOW_COMBO_THRESHOLD = 10;
const int MID_COMBO_THRESHOLD = 30;
const int HIGH_COMBO_THRESHOLD = 50;

class UUIZombieGameplay : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonNumericTextBlock ProgressText;

	UPROPERTY(BindWidget)
	UCommonTextBlock WarningMsg;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation WarningAnim;

	UPROPERTY(BindWidget)
	UCommonTextBlock BossMsg;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation BossMsgAnim;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock ComboText;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock ScoreText;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock HPText;

	UPROPERTY(BindWidget)
	UUIReward RewardUI;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ComboAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ComboEpicAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation AttentionAnim;

	UPROPERTY(BindWidget)
	UUserWidget AttentionButton;

	UPROPERTY(BindWidget)
	UCommonTextBlock AttentionStackText;

	// UPROPERTY(BindWidget)
	// UCommonNumericTextBlock CoinText;

	// UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	// UWidgetAnimation CoinAnim;

	UPROPERTY(BindWidget)
	USlider LevelProgress;

	UPROPERTY(BindWidget)
	UProgressBar CooldownBar;

	UPROPERTY(BindWidget)
	UProgressBar AttentionBar;

	UPROPERTY(Category = Attributes)
	FColor LowComboColor;  // White
	UPROPERTY(Category = Attributes)
	FColor MidComboColor;  // Yellow
	UPROPERTY(Category = Attributes)
	FColor HighComboColor; // Purple

	FVoidEvent EOnAttentionClicked;

	UFUNCTION(BlueprintEvent)
	void UpdateLevelProgress(float NewProgress)
	{
		ProgressText.SetCurrentValue(NewProgress);
		LevelProgress.SetValue(NewProgress);
	}

	UFUNCTION(BlueprintEvent)
	void UpdateCooldownPercent(float NewPercent)
	{
		CooldownBar.SetPercent(NewPercent);
	}

	UFUNCTION(BlueprintEvent)
	void UpdateAttentionPercent(float NewPercent)
	{
		AttentionBar.SetPercent(NewPercent);
	}

	UFUNCTION()
	void DisableCardSpawnUI(bool bDisable)
	{
		if (bDisable)
		{
			AttentionBar.SetVisibility(ESlateVisibility::Hidden);
			AttentionButton.SetVisibility(ESlateVisibility::Hidden);
		}
		else
		{
			AttentionBar.SetVisibility(ESlateVisibility::Visible);
		}
	}

	UFUNCTION()
	void UpdateAttentionStack(int NewStack)
	{
		if (NewStack > 0)
		{
			if (!AttentionStackText.IsVisible())
			{
				AttentionStackText.SetVisibility(ESlateVisibility::Visible);
			}
			AttentionStackText.SetText(FText::FromString("" + NewStack));
		}
		else if (AttentionStackText.IsVisible())
		{
			AttentionStackText.SetVisibility(ESlateVisibility::Hidden);
		}
	}

	UFUNCTION()
	void OnAttentionFull()
	{
		if (!AttentionButton.IsVisible())
		{
			AttentionButton.SetVisibility(ESlateVisibility::Visible);
			PlayAnimation(AttentionAnim, 0, 0);
		}
	}

	UFUNCTION()
	void OnAttentionClicked()
	{
		AttentionButton.SetVisibility(ESlateVisibility::Hidden);
		EOnAttentionClicked.Broadcast();
	}

	UFUNCTION()
	void OnEndGame()
	{
		LevelProgress.SetVisibility(ESlateVisibility::Hidden);
		ScoreText.SetVisibility(ESlateVisibility::Hidden);
		HPText.SetVisibility(ESlateVisibility::Hidden);
		ProgressText.SetVisibility(ESlateVisibility::Hidden);
		CooldownBar.SetVisibility(ESlateVisibility::Hidden);
		AttentionBar.SetVisibility(ESlateVisibility::Hidden);
		AttentionButton.SetVisibility(ESlateVisibility::Hidden);
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

			if (NewValue < HIGH_COMBO_THRESHOLD)
			{
				if (NewValue < LOW_COMBO_THRESHOLD)
				{
					ComboText.SetColorAndOpacity(LowComboColor);
				}
				else if (NewValue < MID_COMBO_THRESHOLD)
				{
					ComboText.SetColorAndOpacity(MidComboColor);
				}
				else
				{
					ComboText.SetColorAndOpacity(HighComboColor);
				}
				PlayAnimation(ComboAnim);
			}
			else
			{
				if (NewValue == HIGH_COMBO_THRESHOLD)
				{
					StopAnimation(ComboAnim);
				}
				PlayAnimation(ComboEpicAnim);
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
			SetVisibility(ESlateVisibility::Hidden);
		}
	}

	UFUNCTION()
	void UpdateBossText(FText NewBossText)
	{
		if (!NewBossText.IsEmpty())
		{
			BossMsg.SetText(NewBossText);
			SetVisibility(ESlateVisibility::SelfHitTestInvisible);
			PlayAnimation(BossMsgAnim);
		}
		else
		{
			SetVisibility(ESlateVisibility::Hidden);
		}
	}

	UFUNCTION(BlueprintCallable)
	void OnNextLevelClicked()
	{
		Cast<ABowlingGameMode>(Gameplay::GetGameMode()).NextLevel();
	}

	UFUNCTION(BlueprintCallable)
	void OnRetryClicked()
	{
		Cast<ABowlingGameMode>(Gameplay::GetGameMode()).RestartGame();
	}
}
