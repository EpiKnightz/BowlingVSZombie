class UUICineText : UUserWidget
{
	UPROPERTY(meta = BindWidget)
	UCommonTextBlock CineCardText;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, meta = (MultiLine = true))
	FText Text;

	// UFUNCTION(BlueprintOverride)
	// void Construct()
	// {
	// 	CineCardText.SetText(FText::FromString("Yoo mama"));
	// }

	// UFUNCTION(BlueprintOverride)
	// void PreConstruct(bool IsDesignTime)
	// {
	// 	CineCardText.SetText(FText::FromString("Yoo mama 1"));
	// }

	UFUNCTION()
	void SetText(FText NewText)
	{
		CineCardText.SetText(NewText);
	}
};