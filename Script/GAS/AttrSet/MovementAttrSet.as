class UMovementAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData MoveSpeed;

	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData MaxSpeed;

	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData Acceleration;

	UMovementAttrSet()
	{
		MoveSpeed.Initialize(50);
		MaxSpeed.Initialize(100);
		Acceleration.Initialize(10);
	}

	UFUNCTION(BlueprintOverride)
	void InitDelegates()
	{
		DOnPreAttrChange.BindUFunction(this, n"PreAttrChange");
		DOnPreBaseAttrChange.BindUFunction(this, n"PreAttrChange");
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