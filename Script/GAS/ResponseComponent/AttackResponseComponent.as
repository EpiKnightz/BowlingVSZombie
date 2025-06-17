class UAttackResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeAttackModifier;
	FObjectIntDelegate DOnRemoveAttackModifier;
	FModDelegate DOnChangeAttackCooldownModifier;
	FObjectIntDelegate DOnRemoveAttackCooldownModifier;

	FVectorReturnDelegate DGetAttackLocation;
	FRotatorReturnDelegate DGetAttackRotation;
	FVectorReturnDelegate DGetOffhandAttackLocation;
	// FRotatorReturnDelegate DGetOffhandAttackRotation;

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
			DPlayAttackAnim.BindUFunction(InteractSystem.Owner, AttackName);
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
	bool IsDualWield()
	{
		return InteractSystem.HasTag(GameplayTags::Description_Weapon_DualWield);
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

	bool IsAttackPaused()
	{
		return DBackupPlayAttackAnim.IsBound();
	}

	UFUNCTION()
	private void OnRemoveAttackCooldownModifier(const UObject Object, int ID)
	{
		InteractSystem.RemoveModifier(AttackAttrSet::AttackCooldown, Object, ID);
	}

	UFUNCTION()
	private void OnChangeAttackCooldownModifier(UModifier Modifier)
	{
		InteractSystem.AddModifier(AttackAttrSet::AttackCooldown, Modifier);
	}

	UFUNCTION()
	void OnChangeAttackModifier(UModifier Modifier)
	{
		InteractSystem.AddModifier(AttackAttrSet::Attack, Modifier);
	}

	UFUNCTION()
	void OnRemoveAttackModifier(const UObject Object, int ID)
	{
		InteractSystem.RemoveModifier(AttackAttrSet::Attack, Object, ID);
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