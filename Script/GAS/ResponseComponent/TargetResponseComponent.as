class UTargetResponseComponent : UResponseComponent
{
	ETargetType TargetType;

	UFUNCTION()
	bool IsTargetable(AActor OtherActor)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		// If the target is untargetable, or the target type matches the target type of the response component, return false.
		if (!IsValid(TargetRC)
			|| TargetRC.TargetType == ETargetType::Untargetable
			|| TargetRC.TargetType == TargetType
			|| TargetRC.TargetType == ETargetType::Player)
		{
			return false;
		}
		return true;
	};

	UFUNCTION()
	bool IsSameTeam(AActor OtherActor)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(TargetRC))
		{
			if (TargetRC.TargetType != TargetType
				&& (TargetRC.TargetType == ETargetType::Zombie || TargetType == ETargetType::Zombie))
			{
				return false;
			}
		}
		return true;
	}
}