
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
	}
};