class UStatusResponseComponent : UActorComponent
{
	FGameplayTagDelegate DOnApplyStatus;

	private AStatusManager StatusManager;

	UFUNCTION()
	void Initialize()
	{

		StatusManager = Gameplay::GetActorOfClass(AStatusManager);
		if (IsValid(StatusManager))
		{
			DOnApplyStatus.BindUFunction(this, n"ApplyStatusEffect");
		}
		else
		{
			PrintError("Can't find StatusManager");
			ForceDestroyComponent();
		}
	}

	UFUNCTION()
	void ApplyStatusEffect(FGameplayTagContainer statusEffect)
	{
		StatusManager.ApplyStatusEffects(statusEffect, GetOwner());
	}
}
