class AAttackBuffZone : AZone
{
	UPROPERTY(DefaultComponent)
	UNiagaraComponent VFXComponent;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		UAttackResponseComponent AttackResponseComponent = UAttackResponseComponent::Get(OtherActor);
		if (IsValid(AttackResponseComponent))
		{
			UMultiplierMod AttackBoost = NewObject(this, UMultiplierMod);
			AttackBoost.ID = 1;
			TArray<float32> Params;
			Params.Add(15);
			AttackBoost.AddParams(Params);
			AttackResponseComponent.DOnChangeAttackModifier.ExecuteIfBound(AttackBoost);
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		UAttackResponseComponent AttackResponseComponent = UAttackResponseComponent::Get(OtherActor);
		if (IsValid(AttackResponseComponent))
		{
			AttackResponseComponent.DOnRemoveAttackModifier.ExecuteIfBound(this, 1);
		}
	}
};