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

		auto AttackResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(AttackResponse))
		{
			UMultiplierMod CooldownMod = NewObject(this, UMultiplierMod);
			CooldownMod.Setup(ModID, 999999);
			AttackResponse.DOnChangeAttackCooldownModifier.ExecuteIfBound(CooldownMod);
		}

		auto StatusResponse = UStatusResponseComponent::Get(GetOwner());
		if (IsValid(StatusResponse))
		{
			StatusResponse.DChangeAddedColor.ExecuteIfBound(FLinearColor::Blue);
		}

		// @ts-ignore
		System::ClearTimer(GetOwner(), "EndHitFlash");
	}

	void EndStatusEffect() override
	{
		auto SpeedResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			SpeedResponse.DOnRemoveMoveSpeedModifier.ExecuteIfBound(this, ModID);
		}

		auto AttackResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(AttackResponse))
		{
			AttackResponse.DOnRemoveAttackCooldownModifier.ExecuteIfBound(this, ModID);
		}

		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DamageResponse.DOnTakeHit.ExecuteIfBound(FindAttrValue(n"PrimaryAttrSet.Damage"));
		}

		auto StatusResponse = UStatusResponseComponent::Get(GetOwner());
		if (IsValid(StatusResponse))
		{
			StatusResponse.DChangeAddedColor.ExecuteIfBound(FLinearColor::Black);
		}

		Super::EndStatusEffect();
	}
}
