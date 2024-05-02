class UDamageResponseComponent : UActorComponent
{
	FFloat2BoolDelegate DOnApplyDamage;
	FFloatDelegate DOnHPRemoval;
	FFloatDelegate DOnDmgBoost;

	FVoidDelegate DOnHitCue;
	FVoidDelegate DOnDamageCue;
	FVoidDelegate DOnDeadCue;

	private UAbilitySystem AbilitySystem;

	UFUNCTION()
	void Initialize(UAbilitySystem iAbilitySystem)
	{
		if (IsValid(AbilitySystem))
		{
			AbilitySystem = iAbilitySystem;
		}
		else
		{
			ForceDestroyComponent();
		}
	}

	// Take Hit -> Take Damage -> Check is Alive -> DamageCue/Dead Cue
	UFUNCTION()
	void TakeHit(float Damage, FGameplayTagContainer StatusEffect)
	{
		DOnHitCue.ExecuteIfBound();

		if (Damage > 0)
		{
			TakeDamage(Damage);
		}
	}

	UFUNCTION()
	void TakeDamage(float Damage)
	{
		AbilitySystem.SetCurrentValue(n"Damage", Damage);
		AbilitySystem.Calculate(n"Damage");
		if (CheckIsAlive())
		{
			DOnDamageCue.ExecuteIfBound();
		}
		else
		{
			DOnDeadCue.ExecuteIfBound();
		}
	}

	UFUNCTION()
	bool CheckIsAlive()
	{
		if (AbilitySystem.GetCurrentValue(n"HP") <= 0)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	UFUNCTION()
	void CheckForStatusEffects(FGameplayTagContainer StatusEffect)
	{
		if (!StatusEffect.IsEmpty())
		{
			UStatusComponent statusComp;
			if (StatusEffect.HasTag(GameplayTags::Status_Negative))
			{
				if (StatusEffect.HasTagExact(GameplayTags::Status_Negative_Burn))
				{
					statusComp = UDoTComponent::GetOrCreate(this.GetOwner(), GameplayTags::Status_Negative_Burn.TagName);
				}
				if (StatusEffect.HasTagExact(GameplayTags::Status_Negative_Chill))
				{
					statusComp = UChillingComponent::GetOrCreate(this.GetOwner(), GameplayTags::Status_Negative_Chill.TagName);
				}
			}
			// FStatusDT Row;
			// ZombieStatusTable.FindRow(Utilities::StatusEnumToFName(status), Row);
			// if (Row.Duration != 0)
			// {
			//
			// 	switch (status)
			// 	{
			// 		case EEffectType::Fire:
			// 			statusComp = UDoTComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status));
			// 			break;
			// 		case EEffectType::Chill:
			// 			statusComp = UChillingComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status));
			// 			break;
			// 		case EEffectType::Freeze:
			// 			statusComp = UFreezeComponent::GetOrCreate(this, Utilities::StatusEnumToComponentName(status));
			// 			break;
			// 		case EEffectType::Poison:
			// 			break;
			// 		default:
			// 			break;
			// 	}
			// 	statusComp.OnInit.BindUFunction(this, n"OnStatusInit");
			// 	statusComp.OnEnd.BindUFunction(this, n"OnStatusEnd");
			// 	statusComp.Init(Row);
			// }
		}
	}
};