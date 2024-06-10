class UMovementAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData MoveSpeed;

	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData MaxSpeed;

	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData Accel;

	// Bounciness affect the bounce speed percentage. 0.8 means 80% of the bounce speed, 0 means no bounce.
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData Bounciness;

	UMovementAttrSet()
	{
		MoveSpeed.Initialize(50);
		MaxSpeed.Initialize(100);
		Accel.Initialize(0);
		Bounciness.Initialize(0.8);
		InitDelegates();
	}

	UFUNCTION(BlueprintOverride)
	void InitDelegates()
	{
		DOnPreAttrChange.BindUFunction(this, n"PreAttrChange");
		DOnPreBaseAttrChange.BindUFunction(this, n"PreAttrChange");
	}

	UFUNCTION(BlueprintOverride)
	void PostInitialize(FName AttrName, float NewValue)
	{
		if (AttrName == MaxSpeed.AttributeName)
		{
			MoveSpeed.Initialize(NewValue);
		}
	}

	UFUNCTION(BlueprintOverride)
	bool PreAttrChange(FName AttrName, float32& NewValue)
	{
		if (AttrName == MoveSpeed.AttributeName)
		{
			if (NewValue == MoveSpeed.GetCurrentValue())
			{
				return true;
			}
			if (NewValue > MaxSpeed.GetCurrentValue() || NewValue < 0)
			{
				NewValue = Math::Clamp(NewValue, 0.0f, MaxSpeed.GetCurrentValue());
			}
		}
		return false;
	}
};