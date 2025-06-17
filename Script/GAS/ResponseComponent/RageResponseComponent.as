const float MAX_RAGE = 100;

class URageResponseComponent : UResponseComponent
{
	float CurrentRage = 0;
	FFloatEvent EOnRageChange;
	FVoidEvent EOnRageHighlightCue;
	FVoidEvent EOnRageFull;
	FVoidEvent EOnRageReset;
	bool bIsRageSkillCasting = false;

	bool InitChild() override
	{
		ComponentTickEnabled = false;
		return true;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		// Becareful of this starting before actual gameplay
		AddRage(DeltaSeconds * InteractSystem.GetValue(RageAttrSet::RageRegen));
	}

	UFUNCTION()
	void OnBeginOverlap(AActor OtherActor)
	{
		if (IsValid(OtherActor))
		{
			auto TargetRespPtr = UTargetResponseComponent::Get(OtherActor);
			if (IsValid(TargetRespPtr) && TargetRespPtr.TargetType == ETargetType::Bowling)
			{
				AddBonusRage();
			}
		}
	}

	UFUNCTION()
	void AddBonusRage()
	{
		AddRage(InteractSystem.GetValue(RageAttrSet::RageBonus));
		EOnRageHighlightCue.Broadcast();
	}

	UFUNCTION()
	void AddRage(float Value)
	{
		if (CurrentRage < MAX_RAGE)
		{
			CurrentRage = Math::Clamp(CurrentRage + Value, 0, MAX_RAGE);
			EOnRageChange.Broadcast(CurrentRage / MAX_RAGE);
			if (CurrentRage >= MAX_RAGE)
			{
				bIsRageSkillCasting = true;
				EOnRageFull.Broadcast();
				// EOnRageHighlightCue.Broadcast();
			}
		}
	}

	UFUNCTION()
	void OnRageSkillEnd()
	{
		// Note becareful with Rage reducing effect
		if (bIsRageSkillCasting)
		{
			bIsRageSkillCasting = false;
			CurrentRage = 0;
			EOnRageChange.Broadcast(CurrentRage);
			EOnRageReset.Broadcast();
		}
	}
};