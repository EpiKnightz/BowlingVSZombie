class UResponseComponent : UActorComponent
{
	protected UInteractSystem InteractSystem;

	UFUNCTION()
	void Initialize(UInteractSystem iAbilitySystem)
	{
		if (IsValid(iAbilitySystem))
		{
			InteractSystem = iAbilitySystem;
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