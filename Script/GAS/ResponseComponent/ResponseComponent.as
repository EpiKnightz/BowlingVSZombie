class UResponseComponent : UActorComponent
{
	protected ULiteAbilitySystem AbilitySystem;

	UFUNCTION()
	void Initialize(ULiteAbilitySystem iAbilitySystem)
	{
		if (IsValid(iAbilitySystem))
		{
			AbilitySystem = iAbilitySystem;
			if (!InitChild())
			{
				Deactive();
			}
		}
		else
		{
			Deactive();
		}
	}

	UFUNCTION()
	protected bool InitChild()
	{
		return true;
	}

	UFUNCTION()
	void Deactive()
	{
		PrintError("DamageResponseComponent: Init unsuccessful.");
		ForceDestroyComponent();
	}
};