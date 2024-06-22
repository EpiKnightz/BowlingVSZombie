class UTargetResponseComponent : UResponseComponent
{
	ETargetType TargetType;

	UFUNCTION()
	bool IsTargetable(AActor OtherActor)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		// If the target is untargetable, or the target type matches the target type of the response component, return false.
		if (!IsValid(TargetRC) || TargetRC.TargetType == ETargetType::Untargetable || TargetRC.TargetType == TargetType)
		{
			return false;
		}
		return true;
	};
}