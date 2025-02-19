struct FKeywordDT
{
	UPROPERTY()
	FText Name;

	UPROPERTY(meta = (MultiLine = true))
	FText Description;

	UPROPERTY()
	FGameplayTag KeywordTag;

	UPROPERTY(EditAnywhere, Category = Appearance)
	UTexture2D Icon;

	UPROPERTY()
	bool bUseCustomColor = false;

	UPROPERTY(meta = (EditCondition = "bUseCustomColor", EditConditionHides))
	FLinearColor CustomColor;

	FKeywordDT(FStatusDT Other)
	{
		if (!Other.Name.IsEmptyOrWhitespace())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
		}
	}
}