class UDurationAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadOnly, Category = "Duration Attribute")
	FAngelscriptGameplayAttributeData Duration;

	UPROPERTY(BlueprintReadOnly, Category = "Interval Attribute")
	FAngelscriptGameplayAttributeData Interval;

	UDurationAttrSet()
	{
		Duration.Initialize(1);
		Interval.Initialize(1);
	}
}