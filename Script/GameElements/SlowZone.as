class ASlowZone : AZone
{
	UPROPERTY()
	float32 DeaccelAddend = 2500;

	private int ModID = 1;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		auto SpeedResponseComponent = UMovementResponseComponent::Get(OtherActor);
		if (IsValid(SpeedResponseComponent))
		{
			UAdditiveMod DeaccelMod = NewObject(this, UAdditiveMod);
			DeaccelMod.Setup(ModID, -DeaccelAddend);
			SpeedResponseComponent.DOnChangeAccelModifier.ExecuteIfBound(DeaccelMod);
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		auto SpeedResponseComponent = UMovementResponseComponent::Get(OtherActor);
		if (IsValid(SpeedResponseComponent))
		{
			SpeedResponseComponent.DOnRemoveAccelModifier.ExecuteIfBound(this, ModID);
		}
	}
}
