namespace PrimaryAttrSet
{
	const FName HP = n"HP";
	const FName MaxHP = n"MaxHP";
	const FName Damage = n"Damage";
	const FName FullDamage = n"PrimaryAttrSet.Damage";
	const FName FullHP = n"PrimaryAttrSet.HP";
	const FName FullMaxHP = n"PrimaryAttrSet.MaxHP";
}
class UPrimaryAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Primary Attribute")
	FAngelscriptGameplayAttributeData HP;

	UPROPERTY(BlueprintReadWrite, Category = "Primary Attribute")
	FAngelscriptGameplayAttributeData MaxHP;

	UPROPERTY(BlueprintReadWrite, Category = "Primary Attribute")
	FAngelscriptGameplayAttributeData Damage;

	UPrimaryAttrSet()
	{
		MaxHP.Initialize(100);
		// HP.Initialize(MaxHP.GetCurrentValue());
		Damage.Initialize(0);
		InitDelegates();
	}

	UFUNCTION(BlueprintOverride, Meta = (BlueprintThreadSafe))
	void InitDelegates()
	{
		DOnPreAttrChange.BindUFunction(this, n"PreAttrChange");
		DOnPreBaseAttrChange.BindUFunction(this, n"PreAttrChange");
		DOnPostCalculation.BindUFunction(this, n"PostCalculation");
	}

	UFUNCTION(BlueprintOverride)
	void PostInitialize(FName AttrName, float NewValue)
	{
		if (AttrName == MaxHP.AttributeName)
		{
			HP.Initialize(NewValue);
		}
	}

	UFUNCTION(BlueprintOverride)
	bool PreAttrChange(FName AttrName, float32& NewValue)
	{
		if (AttrName == HP.AttributeName)
		{
			if (NewValue == HP.GetCurrentValue())
			{
				return true;
			}
			NewValue = Math::Clamp(NewValue, 0.0f, MaxHP.GetCurrentValue());
		}
		return false;
	}

	UFUNCTION(BlueprintOverride)
	void PostCalculation(FName AttrName)
	{
		if (AttrName == Damage.AttributeName)
		{
			Print("Damage: " + Damage.GetCurrentValue());
			HP.SetCurrentValue(Math::Clamp(HP.GetCurrentValue() - Damage.GetCurrentValue(), 0.0f, MaxHP.GetCurrentValue()));
			Damage.Initialize(0);
			// Print("HP: " + HP.GetCurrentValue());
		}
	}
};