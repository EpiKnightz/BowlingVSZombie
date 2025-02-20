namespace DurationAttrSet
{
	const FName Duration = n"Duration";
	const FName Interval = n"Interval";
	const FName FullDuration = n"DurationAttrSet.Duration";
	const FName FullInterval = n"DurationAttrSet.Interval";
}
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