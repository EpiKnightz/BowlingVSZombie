class UAttackResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeAttackModifier;
	FObjectIntDelegate DOnRemoveAttackModifier;
	FModDelegate DOnChangeAttackCooldownModifier;
	FObjectIntDelegate DOnRemoveAttackCooldownModifier;

	FVectorReturnDelegate DGetAttackLocation;
	FRotatorReturnDelegate DGetAttackRotation;

	FVoidEvent EOnAnimHitNotify;
	FVoidEvent EOnAnimEndNotify;
	FVoidDelegate DPlayAttackAnim;
	FVoidEvent EOnPreAttackActivate;
	private FVoidDelegate DBackupPlayAttackAnim;
	FActorEvent EOnBeginOverlapEvent;
	FName2VectorDelegate DGetSocketLocation;

	bool InitChild() override
	{
		DOnChangeAttackModifier.BindUFunction(this, n"OnChangeAttackModifier");
		DOnRemoveAttackModifier.BindUFunction(this, n"OnRemoveAttackModifier");
		DOnChangeAttackCooldownModifier.BindUFunction(this, n"OnChangeAttackCooldownModifier");
		DOnRemoveAttackCooldownModifier.BindUFunction(this, n"OnRemoveAttackCooldownModifier");
		return true;
	}

	UFUNCTION()
	void SetupAttack(FName AttackName)
	{
		if (!AttackName.IsNone())
		{
			DPlayAttackAnim.BindUFunction(AbilitySystem.Owner, AttackName);
		}
	}

	UFUNCTION()
	bool ActivateAttack()
	{
		if (DPlayAttackAnim.IsBound())
		{
			EOnPreAttackActivate.Broadcast();
			DPlayAttackAnim.Execute();
			return true;
		}
		return false;
	}

	UFUNCTION()
	void PauseAttack()
	{
		if (DPlayAttackAnim.IsBound())
		{
			DBackupPlayAttackAnim = DPlayAttackAnim;
			DPlayAttackAnim.Clear();
		}
	}

	UFUNCTION()
	void ResumeAttack()
	{
		if (DBackupPlayAttackAnim.IsBound())
		{
			DPlayAttackAnim = DBackupPlayAttackAnim;
			DBackupPlayAttackAnim.Clear();
		}
	}

	UFUNCTION()
	private void OnRemoveAttackCooldownModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(AttackAttrSet::AttackCooldown, Object, ID);
	}

	UFUNCTION()
	private void OnChangeAttackCooldownModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(AttackAttrSet::AttackCooldown, Modifier);
	}

	UFUNCTION()
	void OnChangeAttackModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(AttackAttrSet::Attack, Modifier);
	}

	UFUNCTION()
	void OnRemoveAttackModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(AttackAttrSet::Attack, Object, ID);
	}

	UFUNCTION()
	void NotifyAttackHit()
	{
		EOnAnimHitNotify.Broadcast();
	}

	UFUNCTION()
	void NotifyAttackEnd()
	{
		EOnAnimEndNotify.Broadcast();
	}
};