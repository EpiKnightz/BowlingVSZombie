class UUIMissionText : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonRichTextBlock MissionText;

	UPROPERTY(BindWidget)
	UImage CheckMark;

	UPROPERTY(BindWidget)
	UButton ButtonTest;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation CheckCompleteAnim;

	int ID;
	FIntEvent OnMissionCompleted;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		ButtonTest.OnClicked.AddUFunction(this, n"OnMouseClicked");
	}

	UFUNCTION()
	private void OnMouseClicked()
	{
		SetCompletion(true);
	}

	UFUNCTION()
	void SetText(FText Text)
	{
		MissionText.SetText(Text);
	}

	UFUNCTION()
	void SetID(int iID)
	{
		ID = iID;
	}

	UFUNCTION()
	void SetCompletion(bool IsCompleted)
	{
		CheckMark.SetVisibility(IsCompleted ? ESlateVisibility::Visible : ESlateVisibility::Hidden);
		if (IsCompleted)
		{
			PlayAnimation(CheckCompleteAnim);
			OnMissionCompleted.Broadcast(ID);
		}
	}

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonUp(FGeometry MyGeometry, FPointerEvent MouseEvent)
	{
		SetCompletion(true);
		return FEventReply();
	}
}