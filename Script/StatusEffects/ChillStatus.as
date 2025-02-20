class UChillStatus : UStatusComponent
{
	bool IsApplicable() override
	{
		UFreezeStatus Target = UFreezeStatus::Get(GetOwner());
		return Super::IsApplicable() && (Target == nullptr || !Target.IsActive());
	}

	void DoInitChildren() override
	{
		auto SpeedResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			UMultiplierMod SpeedMod = NewObject(this, UMultiplierMod);
			SpeedMod.SetupOnce(ModID, 1 - (FindAttrValue(MovementAttrSet::FullMoveSpeed)));
			SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(SpeedMod);
			if (InitTimes >= GetAttrValue(GameplayTags::Status_StatusParam_StackLimit))
			{
				EndStatusEffect();
				auto StatusResponse = UStatusResponseComponent::Get(GetOwner());
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(GameplayTags::Status_Negative_Freeze.GetSingleTagContainer());
				}
			}
		}
	}

	void EndStatusEffect() override
	{
		auto SpeedResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			SpeedResponse.DOnRemoveMoveSpeedModifier.ExecuteIfBound(this, ModID);
		}
		Super::EndStatusEffect();
	}
}
