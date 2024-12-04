const float32 MIN_ATTACK_COOLDOWN = 0.1f;

class UAttackAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Attack Attribute")
	FAngelscriptGameplayAttributeData Attack;

	UPROPERTY(BlueprintReadWrite, Category = "Attack Attribute")
	FAngelscriptGameplayAttributeData AttackCooldown;

	UPROPERTY(BlueprintReadWrite, Category = "Attack Attribute")
	FAngelscriptGameplayAttributeData AttackRange;

	UAttackAttrSet()
	{
		Attack.Initialize(10);
		AttackCooldown.Initialize(1);
		AttackRange.Initialize(50); // <=100 = Melee, >100 = Ranged
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