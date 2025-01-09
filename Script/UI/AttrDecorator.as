class UAttrDecorator : UAttrRTBDecorator
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable EffectDataTable;

	UFUNCTION(BlueprintOverride)
	FText FormatText(FString eff, FString idAttr)
	{
		FText Result;
		FStatusDT StatusRow;
		if (EffectDataTable.FindRow(FName(eff), StatusRow))
		{
			if (idAttr == "Duration")
			{
				Result = FText::FromString("" + StatusRow.Duration + "s");
			}
			else if (idAttr == "Stack")
			{
				float StackCount;
				StatusRow.AffectedAttributes.Find(GameplayTags::Status_StatusParam_StackLimit, StackCount);
				Result = FText::AsNumber(StackCount, FNumberFormattingOptions().SetMaximumFractionalDigits(0));
			}
			else if (idAttr == "MoveSpeed")
			{
				float MoveSpeed;
				StatusRow.AffectedAttributes.Find(FGameplayTag::RequestGameplayTag(n"MovementAttrSet.MoveSpeed"), MoveSpeed);
				Result = FText::AsPercent(MoveSpeed, FNumberFormattingOptions());
			}
			else if (idAttr == "Interval")
			{
				float Interval;
				StatusRow.AffectedAttributes.Find(FGameplayTag::RequestGameplayTag(n"DurationAttrSet.Interval"), Interval);
				Result = FText::FromString("" + Interval + "s");
			}
			else if (idAttr == "Damage")
			{
				float Damage;
				StatusRow.AffectedAttributes.Find(FGameplayTag::RequestGameplayTag(n"PrimaryAttrSet.Damage"), Damage);
				Result = FText::AsNumber(Damage, FNumberFormattingOptions().SetMaximumFractionalDigits(0));
			}
		}
		return Result;
	}
};