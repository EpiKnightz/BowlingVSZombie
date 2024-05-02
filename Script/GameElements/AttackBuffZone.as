class AAttackBuffZone : AZone
{
	UPROPERTY(DefaultComponent)
	UNiagaraComponent VFXComponent;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		UDamageResponseComponent DamageResponseComponent = UDamageResponseComponent::Get(OtherActor);
		if (IsValid(DamageResponseComponent))
		{
			DamageResponseComponent.DOnDmgBoost.ExecuteIfBound(15);
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		UDamageResponseComponent DamageResponseComponent = UDamageResponseComponent::Get(OtherActor);
		if (IsValid(DamageResponseComponent))
		{
			DamageResponseComponent.DOnDmgBoost.ExecuteIfBound(1);
		}
	}
};