struct FKeywordDT
{
	UPROPERTY()
	FText Name;

	UPROPERTY(meta = (MultiLine = true))
	FText Description;

	UPROPERTY(EditAnywhere, Category = Appearance)
	UTexture2D Icon;

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