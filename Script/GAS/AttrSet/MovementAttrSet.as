class UMovementAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData MoveSpeed;

	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData Accel;

	// Bounciness affect the bounce speed percentage. 0.8 means 80% of the bounce speed, 0 means no bounce.
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData Bounciness;

	UMovementAttrSet()
	{
		MoveSpeed.Initialize(150);
		// MaxSpeed.Initialize(100);
		Accel.Initialize(10);
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
	bool PreAttrChange(FName AttrName, float32& NewValue)
	{
		if (AttrName == MoveSpeed.AttributeName)
		{
			if (NewValue == MoveSpeed.GetCurrentValue())
			{
				return true;
			}
		}
		return false;
	}
};