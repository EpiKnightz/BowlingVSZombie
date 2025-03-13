namespace MovementAttrSet
{
	const FName MoveSpeed = n"MoveSpeed";
	const FName Accel = n"Accel";
	const FName Bounciness = n"Bounciness";
	const FName KnockbackResistance = n"KnockbackResistance";
	const FName FullMoveSpeed = n"MovementAttrSet.MoveSpeed";
	const FName FullAccel = n"MovementAttrSet.Accel";
	const FName FullBounciness = n"MovementAttrSet.Bounciness";
	const FName FullKnockbackResistance = n"MovementAttrSet.KnockbackResistance";
}
class UMovementAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData MoveSpeed;

	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData Accel;

	// Bounciness affect the bounce speed percentage. 0.8 means 80% of the bounce speed, 0 means no bounce.
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData Bounciness;

	// KnockbackResistance will prevent knockback from hit if the damage is lower than the resistance.
	UPROPERTY(BlueprintReadWrite, Category = "Movement Attribute")
	FAngelscriptGameplayAttributeData KnockbackResistance;

	UMovementAttrSet()
	{
		MoveSpeed.Initialize(150);
		// MaxSpeed.Initialize(100);
		Accel.Initialize(10);
		Bounciness.Initialize(0.8);
		KnockbackResistance.Initialize(10);
		InitDelegates();
	}

	UFUNCTION(BlueprintOverride, Meta = (BlueprintThreadSafe))
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
				return true; // Mean skip recalculation
			}
		}
		return false;
	}
};