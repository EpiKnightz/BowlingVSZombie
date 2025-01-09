
class UMultiplierPierceAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData FirstPierceMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData SubsequentPierceMultiplier;

	UMultiplierPierceAttrSet()
	{
		FirstPierceMultiplier.Initialize(1.1);
		SubsequentPierceMultiplier.Initialize(0.1);
		// InitDelegates();
	}

	UFUNCTION(BlueprintOverride)
	void PostInitialize(FName AttrName, float NewValue)
	{
		InitDelegates();
	}

	UFUNCTION(BlueprintOverride, Meta = (BlueprintThreadSafe))
	void InitDelegates()
	{
		AActor OuterActor = Cast<AActor>(GetOuter());
		if (IsValid(OuterActor))
		{
			auto MovementResponseComponent = UMovementResponseComponent::Get(OuterActor);
			auto MultiplierResponseComponent = UMultiplierResponseComponent::Get(OuterActor);
			if (IsValid(MovementResponseComponent) && IsValid(MultiplierResponseComponent))
			{
				MultiplierResponseComponent.SetAttrName(FirstPierceMultiplier.AttributeName, SubsequentPierceMultiplier.AttributeName);
				MovementResponseComponent.EOnPierceCue.AddUFunction(MultiplierResponseComponent, n"AddMultiplier");
			}
		}
	}
};