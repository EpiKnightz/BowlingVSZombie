class UUIMissionText : UUserWidget
{
	UPROPERTY(BindWidget)
	UCommonRichTextBlock MissionText;

	UPROPERTY(BindWidget)
	UImage CheckMark;

	UFUNCTION()
	void SetText(FText Text)
	{
		MissionText.SetText(Text);
	}

	UFUNCTION()
	void SetCompletion(bool IsCompleted)
	{
		CheckMark.SetVisibility(IsCompleted ? ESlateVisibility::Visible : ESlateVisibility::Hidden);
	}
}