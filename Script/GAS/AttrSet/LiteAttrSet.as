UCLASS(DefaultToInstanced)
class ULiteAttrSet : ULiteAttrSetBase
{
	/// Will be called in ability system only ///

	// Default return is reversed: false if the attribute can be calculated, true if it cannot. This is because if the event is unbound, it will return false.

	/**
	 *	Called just before any modification happens to an attribute. This is lower level than PreAttributeModify/PostAttribute modify.
	 *	There is no additional context provided here since anything can trigger this. Executed effects, duration based effects, effects being removed, immunity being applied, stacking rules changing, etc.
	 *	This function is meant to enforce things like "Health = Clamp(Health, 0, MaxHealth)" and NOT things like "trigger this extra thing if damage is applied, etc".
	 *
	 *	NewValue is a mutable reference so you are able to clamp the newly applied value as well.
	 */
	UFUNCTION(BlueprintOverride)
	bool PreAttrChange(FName AttrName, float32& NewValue)
	{
		return false;
	}

	/** Called just after any modification happens to an attribute. */
	UFUNCTION(BlueprintOverride)
	void PostAttrChange(FName AttrName)
	{}

	// Default return is reversed: false if the attribute can be calculated, true if it cannot.
	/**
	 *	This is called just before any modification happens to an attribute's base value when an attribute aggregator exists.
	 *	This function should enforce clamping (presuming you wish to clamp the base value along with the final value in PreAttributeChange)
	 *	This function should NOT invoke gameplay related events or callbacks. Do those in PreAttributeChange() which will be called prior to the
	 *	final value of the attribute actually changing.
	 */
	UFUNCTION(BlueprintOverride)
	bool PreBaseAttrChange(FName AttrName, float32& NewValue)
	{
		return false;
	}

	/** Called just after any modification happens to an attribute's base value when an attribute aggregator exists. */
	UFUNCTION(BlueprintOverride)
	void PostBaseAttrChange(FName AttrName)
	{}

	// Will be called in ability system only. Default return is reversed: false if the attribute can be calculated, true if it cannot.

	/**
	 *	Called just before modifying the value of an attribute. AttributeSet can make additional modifications here. Return true to continue, or false to throw out the modification.
	 *	Note this is only called during an 'execute'. E.g., a modification to the 'base value' of an attribute. It is not called during an application of a GameplayEffect, such as a 5 ssecond +10 movement speed buff.
	 */
	UFUNCTION(BlueprintOverride)
	bool PreCalculation(FName AttrName)
	{
		return false;
	}

	// Will be called in ability system only
	/**
	 *	Called just before a GameplayEffect is executed to modify the base value of an attribute. No more changes can be made.
	 *	Note this is only called during an 'execute'. E.g., a modification to the 'base value' of an attribute. It is not called during an application of a GameplayEffect, such as a 5 ssecond +10 movement speed buff.
	 */
	UFUNCTION(BlueprintOverride)
	void PostCalculation(FName AttrName)
	{}
};