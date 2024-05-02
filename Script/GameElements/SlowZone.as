class ASlowZone : AZone
{
	UPROPERTY()
	float DeaccelAddend = 2500;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		auto SpeedResponseComponent = USpeedResponseComponent::Get(OtherActor);
		if (IsValid(SpeedResponseComponent))
		{
			SpeedResponseComponent.DOnChangeAccelModifier.ExecuteIfBound(DeaccelAddend);
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		auto SpeedResponseComponent = USpeedResponseComponent::Get(OtherActor);
		if (IsValid(SpeedResponseComponent))
		{
			SpeedResponseComponent.DOnChangeAccelModifier.ExecuteIfBound(0);
		}
	}
}
