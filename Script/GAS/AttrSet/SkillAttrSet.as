const float32 MIN_SKILL_COOLDOWN = 0.1f;
class USkillAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Skill Attribute")
	FAngelscriptGameplayAttributeData SkillAttackModifier;

	UPROPERTY(BlueprintReadWrite, Category = "Skill Attribute")
	FAngelscriptGameplayAttributeData SkillCooldownModifier;

	UPROPERTY(BlueprintReadWrite, Category = "Skill Attribute")
	FAngelscriptGameplayAttributeData SkillRangeModifier;

	USkillAttrSet()
	{
		SkillAttackModifier.Initialize(1);
		SkillCooldownModifier.Initialize(1);
		SkillRangeModifier.Initialize(1); // <=100 = Melee, >100 = Ranged
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
		if (AttrName == SkillCooldownModifier.AttributeName
			|| AttrName == SkillRangeModifier.AttributeName
			|| AttrName == SkillAttackModifier.AttributeName)
		{
			if (NewValue <= 0)
			{
				NewValue = MIN_SKILL_COOLDOWN;
			}
		}
		return true;
	}
};