const float VERTICALBOX_SPACING = 135;
const float BASE_TOP_PADDING = 232.5;
const float BASE_RIGHT_PADDING = -482.5;
class UUIMissionsList : UUserWidget
{
	UPROPERTY(BindWidget)
	UVerticalBox VerticalBox;

	UPROPERTY(BindWidget)
	UImage Pencil;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation CheckAnim;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	TSubclassOf<UUIMissionText> MissionTextClass;

	TMap<FName, UUIMissionText> MissionTexts;

	FFloatEvent OnMissionCompletedAnim;

	UFUNCTION()
	void UpdateMissionList(TArray<FAchievementData> Missions, TArray<FAchievementStates> States)
	{
		for (int i = 0; i < Missions.Num(); i++)
		{
			if (!States[i].Acknowledged)
			{
				UUIMissionText MissionText = Cast<UUIMissionText>(WidgetBlueprint::CreateWidget(MissionTextClass, Gameplay::GetPlayerController(0)));
				MissionText.SetText(Missions[i].DisplayName);
				MissionText.SetCompletion(States[i].Achieved);
				MissionText.SetID(MissionTexts.Num());
				MissionText.OnMissionCompleted.AddUFunction(this, n"OnMissionCompleted");
				VerticalBox.AddChildToVerticalBox(MissionText);

				MissionTexts.Add(Missions[i].Key, MissionText);
			}
		}
		Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
	}

	UFUNCTION()
	void OnMissionCompleted(int ID)
	{
		float Spacing = VERTICALBOX_SPACING * ID;
		Cast<UOverlaySlot>(Pencil.Slot).SetPadding(FMargin(0, BASE_TOP_PADDING + Spacing, BASE_RIGHT_PADDING, 0));
		Pencil.SetVisibility(ESlateVisibility::Visible);
		PlayAnimation(CheckAnim);
		OnMissionCompletedAnim.Broadcast(Spacing);
	}

	UFUNCTION(BlueprintOverride)
	void OnAnimationFinished(const UWidgetAnimation Animation)
	{
		if (Animation == CheckAnim)
		{
			Pencil.SetVisibility(ESlateVisibility::Collapsed);
		}
	}

	UFUNCTION()
	void MissionCompleted(FName Key)
	{
		UUIMissionText OutMissionText;
		if (MissionTexts.Find(Key, OutMissionText))
		{
			OutMissionText.SetCompletion(true);
		}
	}
}