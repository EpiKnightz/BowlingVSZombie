
class UMultiplierBuffAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData FirstBuffMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData SubsequentBuffMultiplier;

	UMultiplierBuffAttrSet()
	{
		FirstBuffMultiplier.Initialize(1.1);
		SubsequentBuffMultiplier.Initialize(0.1);
		InitDelegates();
	}

	UFUNCTION(BlueprintOverride)
	void InitDelegates()
	{
		AActor OuterActor = Cast<AActor>(GetOuter());
		if (IsValid(OuterActor))
		{
		}
	}
};