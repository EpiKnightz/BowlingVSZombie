class UFreezeStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto SpeedResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(SpeedResponse))
		{
			UMultiplierMod SpeedMod = NewObject(this, UMultiplierMod);
			SpeedMod.SetupOnce(ModID, 0);
			SpeedResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(SpeedMod);
		}

		auto AttackResponse = UAttackResponseComponent::Get(GetOwner());
		if (IsValid(AttackResponse))
		{
			AttackResponse.PauseAttack();
		}

		auto StatusResponse = UStatusResponseComponent::Get(GetOwner());
		if (IsValid(StatusResponse))
		{
			StatusResponse.DChangeOverlayColor.ExecuteIfBound(FLinearColor::Blue, true);
		}

		// FString FunctionName = "ResetOverlayColor";
		// System::ClearTimer(GetOwner(), FunctionName);
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
			AttackResponse.ResumeAttack();
		}

		auto StatusResponse = UStatusResponseComponent::Get(GetOwner());
		if (IsValid(StatusResponse))
		{
			StatusResponse.DChangeOverlayColor.ExecuteIfBound(FLinearColor::Transparent, true);
		}

		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DamageResponse.DOnTakeHit.ExecuteIfBound(FindAttrValue(PrimaryAttrSet::FullDamage));
		}

		Super::EndStatusEffect();
	}
}
