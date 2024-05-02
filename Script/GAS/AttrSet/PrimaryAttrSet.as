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
		HP.Initialize(MaxHP.GetCurrentValue());
		Damage.Initialize(0);
	}

	UFUNCTION(BlueprintOverride)
	void PostInitialize(FName AttrName, float NewValue)
	{
		if (AttrName == MaxHP.AttributeName)
		{
			HP.Initialize(MaxHP.GetCurrentValue());
		}
	}

	UFUNCTION(BlueprintOverride)
	void PreAttrChange(FName AttrName, float32& NewValue)
	{
		if (AttrName == HP.AttributeName)
		{
			if (NewValue > MaxHP.GetCurrentValue() || NewValue < 0)
			{
				NewValue = Math::Clamp(NewValue, 0.0f, MaxHP.GetCurrentValue());
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	void PostCalculation(FAngelscriptGameplayAttributeData& Data)
	{
		if (Data.AttributeName == Damage.AttributeName)
		{
			HP.SetCurrentValue(Math::Clamp(HP.GetCurrentValue() - Damage.GetCurrentValue(), 0.0f, MaxHP.GetCurrentValue()));
			Damage.Initialize(0);
		}
	}
};