class UFreezeComponent : UStatusComponent
{
	void DoInitChildren() override
	{
		auto SpeedResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			UMultiplierMod SpeedMod = NewObject(this, UMultiplierMod);
			SpeedMod.Setup(ModID, 0);
			SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(SpeedMod);
		}
	}

	void EndStatusEffect() override
	{
		auto SpeedResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			SpeedResponse.DOnRemoveMoveSpeedModifier.ExecuteIfBound(this, ModID);
		}

		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DamageResponse.DOnTakeHit.ExecuteIfBound(FindAttrValue(n"PrimaryAttrSet.Damage"));
		}
		Super::EndStatusEffect();
	}
}
