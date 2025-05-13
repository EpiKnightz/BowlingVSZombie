const float HAND_X_PADDING = 660;
const float HAND_Y_PADDING = -245;
const float BASE_HAND_X_PADDING = 210;
const float BASE_HAND_Y_PADDING = 765;

class UUIBoard : UUserWidget
{
	UPROPERTY(BindWidget)
	UUIMissionsList MissionList;

	UPROPERTY(BindWidget)
	UUIMap Map;

	UPROPERTY(BindWidget)
	UButton NextButton;

	UPROPERTY(BindWidget)
	UImage Hand;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation NextAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation PaperRipAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation IntroAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation IdleAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation LeftRightAnim;
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation MapNextAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation MissionCheckAnim;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		PlayAnimation(IntroAnim);
	}

	UFUNCTION()
	void OnIntroFinished()
	{
		PlayAnimation(NextAnim, 0, 0);
		NextButton.SetVisibility(ESlateVisibility::Visible);
		NextButton.OnClicked.AddUFunction(this, n"OnNextButtonClicked");
		MissionList.OnMissionCompletedAnim.AddUFunction(this, n"OnMissionCompletedAnim");
	}

	UFUNCTION(BlueprintOverride)
	void OnAnimationFinished(const UWidgetAnimation Animation)
	{
		if (Animation == IntroAnim)
		{
			OnIntroFinished();
			PlayAnimation(IdleAnim, 0, 0);
		}
		else if (Animation == PaperRipAnim)
		{
			PlayAnimation(IdleAnim, 0, 0);
		}
		else if (Animation == MissionCheckAnim)
		{
			Cast<UCanvasPanelSlot>(Hand.Slot).SetPosition(FVector2D(BASE_HAND_X_PADDING, BASE_HAND_Y_PADDING));
			Hand.SetRenderTranslation(FVector2D::ZeroVector);
		}
	}

	UFUNCTION()
	private void OnNextButtonClicked()
	{
		StopAnimation(NextAnim);
		NextButton.SetVisibility(ESlateVisibility::Collapsed);

		PlayAnimation(PaperRipAnim);
		Map.Start();
		Map.OnLeftClicked.AddUFunction(this, n"OnLeftRightClicked");
		Map.OnRightClicked.AddUFunction(this, n"OnLeftRightClicked");
		Map.OnNextClicked.AddUFunction(this, n"OnNextClicked");
	}

	UFUNCTION()
	private void OnMissionCompletedAnim(float Value)
	{
		Cast<UCanvasPanelSlot>(Hand.Slot).SetPosition(FVector2D(HAND_X_PADDING, HAND_Y_PADDING + Value));
		PlayAnimation(MissionCheckAnim);
	}

	UFUNCTION()
	private void OnLeftRightClicked()
	{
		PlayAnimation(LeftRightAnim);
	}

	UFUNCTION()
	private void OnNextClicked()
	{
		PlayAnimation(MapNextAnim);
	}

	UFUNCTION()
	void UpdateMissionList(TArray<FAchievementData> Missions, TArray<FAchievementStates> States)
	{
		MissionList.UpdateMissionList(Missions, States);
	}
}