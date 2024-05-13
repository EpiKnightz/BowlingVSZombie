class UResponseComponent : UActorComponent
{
	protected UAbilitySystem AbilitySystem;

	UFUNCTION()
	void Initialize(UAbilitySystem iAbilitySystem)
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