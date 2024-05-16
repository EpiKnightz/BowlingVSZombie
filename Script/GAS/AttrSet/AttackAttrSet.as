const float32 MIN_ATTACK_COOLDOWN = 0.1f;

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
	bool PreAttrChange(FName AttrName, float32& NewValue)
	{
		if (AttrName == n"AttackCooldown")
		{
			if (NewValue <= 0)
			{
				NewValue = MIN_ATTACK_COOLDOWN;
			}
		}
		return true;
	}
};