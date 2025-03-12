const float32 MIN_ATTACK_COOLDOWN = 0.1f;

namespace AttackAttrSet
{
	const FName Attack = n"Attack";
	const FName AttackCooldown = n"AttackCooldown";
	const FName AttackRange = n"AttackRange";
	const FName FullAttack = n"AttackAttrSet.Attack";
	const FName FullAttackCooldown = n"AttackAttrSet.AttackCooldown";
	const FName FullAttackRange = n"AttackAttrSet.AttackRange";
}

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
		InitDelegates();
	}

	UFUNCTION(BlueprintOverride, Meta = (BlueprintThreadSafe))
	void InitDelegates()
	{
		DOnPreAttrChange.BindUFunction(this, n"PreAttrChange");
	}

	UFUNCTION(BlueprintOverride)
	bool PreAttrChange(FName AttrName, float32& NewValue)
	{
		if (AttrName == AttackCooldown.AttributeName)
		{
			if (NewValue <= 0)
			{
				NewValue = MIN_ATTACK_COOLDOWN;
			}
		}
		return false;
	}
};