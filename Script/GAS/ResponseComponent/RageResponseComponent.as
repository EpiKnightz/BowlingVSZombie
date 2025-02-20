const float MAX_RAGE = 100;

class URageResponseComponent : UResponseComponent
{
	float CurrentRage = 0;
	FFloatEvent EOnRageChange;
	FVoidEvent EOnRageFull;
	FVoidEvent EOnRageReset;

	bool InitChild() override
	{
		ComponentTickEnabled = false;
		return true;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		// Becareful of this starting before actual gameplay
		AddRage(DeltaSeconds * AbilitySystem.GetValue(RageAttrSet::RageRegen));
	}

	UFUNCTION()
	void AddRage(float Value)
	{
		if (CurrentRage < 100)
		{
			CurrentRage = Math::Clamp(CurrentRage + Value, 0, MAX_RAGE);
			EOnRageChange.Broadcast(CurrentRage / MAX_RAGE);
			if (CurrentRage >= MAX_RAGE)
			{
				EOnRageFull.Broadcast();
				CurrentRage = 0;
				EOnRageChange.Broadcast(CurrentRage);
				EOnRageReset.Broadcast();
			}
		}
	}
};