class UFreezeStatus : UStatusComponent
{
	void DoInitChildren() override
	{
		auto MovementResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(MovementResponse))
		{
			UMultiplierMod SpeedMod = NewObject(this, UMultiplierMod);
			SpeedMod.SetupOnce(ModID, 0);
			MovementResponse.DOnChangeMoveSpeedModifier.ExecuteIfBound(SpeedMod);
			MovementResponse.EnableMovement(false);
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

		auto DamageResponse = UDamageResponseComponent::Get(GetOwner());
		if (IsValid(DamageResponse))
		{
			DamageResponse.EOnHitCue.AddUFunction(this, n"EndStatusEffect");
		}
		// FString FunctionName = "ResetOverlayColor";
		// System::ClearTimer(GetOwner(), FunctionName);
	}

	void EndStatusEffect() override
	{
		auto MovementResponse = UMovementResponseComponent::Get(GetOwner());
		if (IsValid(MovementResponse))
		{
			MovementResponse.EnableMovement(true);
			MovementResponse.DOnRemoveMoveSpeedModifier.ExecuteIfBound(this, ModID);
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
			DamageResponse.EOnHitCue.Unbind(this, n"EndStatusEffect");
			DamageResponse.DOnTakeHit.ExecuteIfBound(FindAttrValue(PrimaryAttrSet::FullDamage));
		}

		Super::EndStatusEffect();
	}
}
