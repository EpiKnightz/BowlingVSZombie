
class UMultiplierAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData FirstMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData SubsequentMultiplier;

	UMultiplierAttrSet()
	{
		FirstMultiplier.Initialize(1.5); // TODO: Remember to change back to 1.2, for testing only
		SubsequentMultiplier.Initialize(0.1);
	}
};