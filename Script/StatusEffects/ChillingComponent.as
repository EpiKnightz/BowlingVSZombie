class UChillingComponent : UStatusComponent
{
	private int ModID = 1;

	bool IsApplicable() override
	{
		UFreezeComponent Target = UFreezeComponent::Get(GetOwner());
		return Super::IsApplicable() && (Target == nullptr || !Target.IsActive());
	}

	void DoInitChildren() override
	{
		auto SpeedResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			UMultiplierMod SpeedMod = NewObject(this, UMultiplierMod);
			SpeedMod.Setup(ModID, float32(1 - (FindAttrValue(n"MovementAttrSet.MoveSpeed") * InitTimes)));
			SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(SpeedMod);
			if (InitTimes >= GetAttrValue(GameplayTags::StatusParam_StackLimit))
			{
				EndStatusEffect();
				auto StatusResponse = UStatusResponseComponent::Get(GetOwner());
				if (IsValid(StatusResponse))
				{
					StatusResponse.DOnApplyStatus.ExecuteIfBound(GameplayTag::MakeGameplayTagContainerFromTag(GameplayTags::Status_Negative_Freeze));
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
