class UUICineText : UUserWidget
{
	UPROPERTY(meta = BindWidget)
	UCommonTextBlock CineCardText;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, meta = (MultiLine = true))
	FText Text;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		Print(Text.ToString());
		CineCardText.SetText(FText::FromString("Yoo mama"));
	}

	UFUNCTION(BlueprintOverride)
	void PreConstruct(bool IsDesignTime)
	{
		Print(Text.ToString());
		CineCardText.SetText(FText::FromString("Yoo mama 1"));
	}

	UFUNCTION()
	void SetText(FText NewText)
	{
		Print(NewText.ToString());
		CineCardText.SetText(NewText);
	}
};