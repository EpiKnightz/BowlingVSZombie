class URageAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Rage Attribute")
	FAngelscriptGameplayAttributeData InitialRage;

	UPROPERTY(BlueprintReadWrite, Category = "Rage Attribute")
	FAngelscriptGameplayAttributeData RageRegen;

	UPROPERTY(BlueprintReadWrite, Category = "Rage Attribute")
	FAngelscriptGameplayAttributeData RageBonus;

	URageAttrSet()
	{
		InitialRage.Initialize(0);
		RageRegen.Initialize(1);
		RageBonus.Initialize(10);
	}
}