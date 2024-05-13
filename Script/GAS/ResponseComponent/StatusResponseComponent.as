class UStatusResponseComponent : UResponseComponent
{
	FGameplayTagDelegate DOnApplyStatus;

	private AStatusManager StatusManager;

	bool InitChild() override
	{
		StatusManager = Gameplay::GetActorOfClass(AStatusManager);
		if (IsValid(StatusManager))
		{
			DOnApplyStatus.BindUFunction(this, n"ApplyStatusEffect");
			return true;
		}
		else
		{
			return false;
		}
	}

	UFUNCTION()
	void ApplyStatusEffect(FGameplayTagContainer statusEffect)
	{
		StatusManager.ApplyStatusEffects(statusEffect, GetOwner());
	}
}
