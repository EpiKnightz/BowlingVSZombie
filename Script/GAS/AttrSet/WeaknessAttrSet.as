namespace WeaknessAttrSet
{
	const FName FireWeaknessMultiplier = n"FireWeaknessMultiplier";
	const FName WaterWeaknessMultiplier = n"WaterWeaknessMultiplier";
	const FName ForestWeaknessMultiplier = n"ForestWeaknessMultiplier";
	const FName EarthWeaknessMultiplier = n"EarthWeaknessMultiplier";
	const FName AetherWeaknessMultiplier = n"AetherWeaknessMultiplier";
	const FName NetherWeaknessMultiplier = n"NetherWeaknessMultiplier";
	const FName VoidWeaknessMultiplier = n"VoidWeaknessMultiplier";
	const FName FullFireWeaknessMultiplier = n"WeaknessAttrSet.FireWeaknessMultiplier";
	const FName FullWaterWeaknessMultiplier = n"WeaknessAttrSet.WaterWeaknessMultiplier";
	const FName FullForestWeaknessMultiplier = n"WeaknessAttrSet.ForestWeaknessMultiplier";
	const FName FullEarthWeaknessMultiplier = n"WeaknessAttrSet.EarthWeaknessMultiplier";
	const FName FullAetherWeaknessMultiplier = n"WeaknessAttrSet.AetherWeaknessMultiplier";
	const FName FullNetherWeaknessMultiplier = n"WeaknessAttrSet.NetherWeaknessMultiplier";
	const FName FullVoidWeaknessMultiplier = n"WeaknessAttrSet.VoidWeaknessMultiplier";

	FName TagToWeakness(FGameplayTag Element)
	{
		if (Element == GameplayTags::Description_Element_Fire)
			return WeaknessAttrSet::FireWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Water)
			return WeaknessAttrSet::WaterWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Forest)
			return WeaknessAttrSet::ForestWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Earth)
			return WeaknessAttrSet::EarthWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Aether)
			return WeaknessAttrSet::AetherWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Nether)
			return WeaknessAttrSet::NetherWeaknessMultiplier;
		else
			return WeaknessAttrSet::VoidWeaknessMultiplier;
	}

	FName TagToFullWeakness(FGameplayTag Element)
	{
		if (Element == GameplayTags::Description_Element_Fire)
			return WeaknessAttrSet::FullFireWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Water)
			return WeaknessAttrSet::FullWaterWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Forest)
			return WeaknessAttrSet::FullForestWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Earth)
			return WeaknessAttrSet::FullEarthWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Aether)
			return WeaknessAttrSet::FullAetherWeaknessMultiplier;
		else if (Element == GameplayTags::Description_Element_Nether)
			return WeaknessAttrSet::FullNetherWeaknessMultiplier;
		else
			return WeaknessAttrSet::FullVoidWeaknessMultiplier;
	}
}

class UWeaknessAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Weakness Attribute")
	FAngelscriptGameplayAttributeData FireWeaknessMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Weakness Attribute")
	FAngelscriptGameplayAttributeData WaterWeaknessfMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Weakness Attribute")
	FAngelscriptGameplayAttributeData ForestWeaknessMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Weakness Attribute")
	FAngelscriptGameplayAttributeData EarthWeaknessMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Weakness Attribute")
	FAngelscriptGameplayAttributeData AetherWeaknessMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Weakness Attribute")
	FAngelscriptGameplayAttributeData NetherWeaknessMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Weakness Attribute")
	FAngelscriptGameplayAttributeData VoidWeaknessMultiplier;

	UWeaknessAttrSet()
	{
		FireWeaknessMultiplier.Initialize(1);
		WaterWeaknessfMultiplier.Initialize(1);
		ForestWeaknessMultiplier.Initialize(1);
		EarthWeaknessMultiplier.Initialize(1);
		AetherWeaknessMultiplier.Initialize(1);
		NetherWeaknessMultiplier.Initialize(1);
		VoidWeaknessMultiplier.Initialize(1);
	}
};