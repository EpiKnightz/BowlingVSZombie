class UAttackAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Attack Attribute")
	FAngelscriptGameplayAttributeData Attack;

	UPROPERTY(BlueprintReadWrite, Category = "Attack Attribute")
	FAngelscriptGameplayAttributeData AttackCooldown;

	UAttackAttrSet()
	{
		Attack.Initialize(10);
		AttackCooldown.Initialize(1);
	}
};