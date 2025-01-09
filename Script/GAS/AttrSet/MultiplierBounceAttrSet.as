
class UMultiplierBounceAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData FirstBounceMultiplier;

	UPROPERTY(BlueprintReadWrite, Category = "Multiplier Attribute")
	FAngelscriptGameplayAttributeData SubsequentBounceMultiplier;

	UMultiplierBounceAttrSet()
	{
		FirstBounceMultiplier.Initialize(1.1);
		SubsequentBounceMultiplier.Initialize(0.1);
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
				MultiplierResponseComponent.SetAttrName(FirstBounceMultiplier.AttributeName, SubsequentBounceMultiplier.AttributeName);
				MovementResponseComponent.EOnPostAddForce.AddUFunction(MultiplierResponseComponent, n"AddMultiplier");
				MovementResponseComponent.EOnPostBounce.AddUFunction(MultiplierResponseComponent, n"AddMultiplier");
			}
		}
	}
};