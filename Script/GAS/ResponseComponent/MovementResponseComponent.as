class UMovementResponseComponent : UResponseComponent
{
	FModDelegate DOnChangeMoveSpeedModifier;
	FObjectIntDelegate DOnRemoveMoveSpeedModifier;
	FModDelegate DOnChangeAccelModifier;
	FObjectIntDelegate DOnRemoveAccelModifier;

	bool InitChild() override
	{
		DOnChangeMoveSpeedModifier.BindUFunction(this, n"OnChangeMoveSpeedModifier");
		DOnRemoveMoveSpeedModifier.BindUFunction(this, n"OnRemoveMoveSpeedModifier");
		DOnChangeAccelModifier.BindUFunction(this, n"OnChangeAccelModifier");
		DOnRemoveAccelModifier.BindUFunction(this, n"OnRemoveAccelModifier");
		return true;
	}

	UFUNCTION()
	private void OnChangeMoveSpeedModifier(UModifier Modifier){
		AbilitySystem.AddModifier(n"MoveSpeed", Modifier);
	}
	UFUNCTION()
	private void OnRemoveMoveSpeedModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(n"MoveSpeed", Object, ID);
	}

	UFUNCTION()
	private void OnChangeAccelModifier(UModifier Modifier)
	{
		AbilitySystem.AddModifier(n"Acceleration", Modifier);
	}

	UFUNCTION()
	private void OnRemoveAccelModifier(const UObject Object, int ID)
	{
		AbilitySystem.RemoveModifier(n"Acceleration", Object, ID);
	}
};