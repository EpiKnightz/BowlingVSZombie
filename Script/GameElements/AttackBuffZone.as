class AAttackBuffZone : AZone
{
	UPROPERTY(DefaultComponent)
	UNiagaraComponent VFXComponent;

	UPROPERTY()
	float32 AttackBoostAmount = 15;

	private int ModID = 1;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		UAttackResponseComponent AttackResponseComponent = UAttackResponseComponent::Get(OtherActor);
		if (IsValid(AttackResponseComponent))
		{
			UMultiplierMod AttackBoost = NewObject(this, UMultiplierMod);
			AttackBoost.Setup(ModID, AttackBoostAmount);
			AttackResponseComponent.DOnChangeAttackModifier.ExecuteIfBound(AttackBoost);
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		UAttackResponseComponent AttackResponseComponent = UAttackResponseComponent::Get(OtherActor);
		if (IsValid(AttackResponseComponent))
		{
			AttackResponseComponent.DOnRemoveAttackModifier.ExecuteIfBound(this, ModID);
		}
	}
};