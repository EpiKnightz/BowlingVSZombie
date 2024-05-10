class UTargetResponseComponent : UActorComponent
{
	ETargetType TargetType;

	UFUNCTION()
	bool IsTargetable(AActor OtherActor)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		if (!IsValid(TargetRC) || TargetRC.TargetType == ETargetType::Untargetable || TargetRC.TargetType == TargetType)
		{
			return false;
		}
		return true;
	};
}