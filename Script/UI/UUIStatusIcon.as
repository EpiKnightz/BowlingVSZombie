class UUIStatusIcon : UUserWidget
{
	UPROPERTY(BindWidget)
	UImage StatusIcon;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation StatusExpireAnimation;

	UPROPERTY(BindWidget)
	UCommonNumericTextBlock StatusStack;

	private UTexture2D DefaultIcon;

	UFUNCTION()
	void Init(UTexture2D Icon)
	{
		DefaultIcon = Icon;
		StatusIcon.SetBrushFromTexture(Icon);
		// StatusIcon.SetBrush(Icon);
	}

	UFUNCTION()
	void FadeStatusIconWithTime(float TimeLeft)
	{
		if (StatusIcon.IsVisible())
		{
			PlayAnimation(StatusExpireAnimation, Math::Max(0, StatusExpireAnimation.GetEndTime() - TimeLeft));
		}
	}

	UFUNCTION()
	void FadeStatusIcon()
	{
		if (StatusIcon.IsVisible())
		{
			PlayAnimation(StatusExpireAnimation);
		}
	}

	UFUNCTION()
	void OnDurationChanged(float NewDuration)
	{
		System::ClearTimer(this, "FadeStatusIcon");
		StopAnimation(StatusExpireAnimation);
		StatusIcon.SetVisibility(ESlateVisibility::Visible);
		if (NewDuration <= StatusExpireAnimation.GetEndTime())
		{
			FadeStatusIconWithTime(NewDuration);
		}
		else
		{
			System::SetTimer(this, n"FadeStatusIcon", NewDuration - StatusExpireAnimation.GetEndTime(), false);
		}
	}

	UFUNCTION()
	void OnStackChanged(int NewStack)
	{
		if (NewStack > 1)
		{
			StatusStack.SetVisibility(ESlateVisibility::Visible);
			StatusStack.SetCurrentValue(NewStack);
		}
		else
		{
			StatusStack.SetVisibility(ESlateVisibility::Hidden);
		}
	}

	UFUNCTION()
	void OnEndStatusEffect()
	{
		StatusIcon.SetVisibility(ESlateVisibility::Hidden);
		StatusStack.SetVisibility(ESlateVisibility::Hidden);
		RemoveWidget(this);
	}

	UFUNCTION()
	void SetEtc(UTexture2D Icon, bool IsEtc = true)
	{
		if (IsEtc)
		{
			StatusIcon.SetBrushFromTexture(Icon);
		}
		else
		{
			StatusIcon.SetBrushFromTexture(DefaultIcon);
		}
	}
}