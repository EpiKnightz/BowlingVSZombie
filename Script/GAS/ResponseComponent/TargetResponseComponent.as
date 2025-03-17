class UTargetResponseComponent : UResponseComponent
{
	UPROPERTY()
	ETargetType TargetType;
	FGameplayTag TargetID;

	UFUNCTION()
	void SetID(FGameplayTag iID)
	{
		if (iID.GetCurrentNameOnly().ToString().Contains("Lv"))
		{
			TargetID = iID.RequestDirectParent();
		}
		else
		{
			TargetID = iID;
		}
	}

	UFUNCTION()
	void GetInfoFromHost(UTargetResponseComponent Host, FGameplayTag AltID = FGameplayTag())
	{
		TargetType = Host.TargetType;
		if (AltID.IsValid())
		{
			TargetID = AltID;
		}
		else
		{
			TargetID = Host.TargetID;
		}
	}

	UFUNCTION()
	bool IsTargetable(AActor OtherActor, bool bTargetAlly = false)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		// If the target is untargetable, or the target type matches the target type of the response component, return false.
		if (!IsValid(TargetRC)
			|| TargetRC.TargetType == ETargetType::Untargetable
			|| (!bTargetAlly && TargetRC.TargetType == TargetType)
			|| TargetRC.TargetType == ETargetType::Player)
		{
			return false;
		}
		return true;
	};

	UFUNCTION()
	bool IsZombie(AActor OtherActor)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(TargetRC)
			&& TargetRC.TargetType == ETargetType::Zombie)
		{
			return true;
		}
		return false;
	}

	UFUNCTION()
	bool IsPierceable(AActor OtherActor)
	{
		auto TargetRC = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(TargetRC)
			&& (TargetRC.TargetType == ETargetType::Zombie
				|| TargetRC.TargetType == ETargetType::Survivor))
		{
			return true;
		}
		else
		{
			return false;
		}
	}

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