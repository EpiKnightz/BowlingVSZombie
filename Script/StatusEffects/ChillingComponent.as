class UChillingComponent : UStatusComponent
{
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
			SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(1 - (FindAttrValue(n"MoveableAttrSet.MoveSpeed") * InitTimes));
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
			SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(1);
		}
		Super::EndStatusEffect();
	}
}
