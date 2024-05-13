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
		DOnPostAttrChange.BindUFunction(this, n"PostAttrChange");
	}

	UFUNCTION(BlueprintOverride)
	void PostAttrChange(FName AttrName)
	{
		Print("Attack: " + Attack.GetCurrentValue());
		Print("AttackCooldown: " + AttackCooldown.GetCurrentValue());
	}
};