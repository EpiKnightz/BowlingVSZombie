// Use these for one time effect, or stuff that last permanently, doesn't care about end effect
class UModifierObject : UDataAsset
{
	UPROPERTY()
	FName AttributeName;

	UPROPERTY()
	bool bForceRecalculation = false;

	protected int ID = 0;

	UFUNCTION()
	void AddToAbilitySystem(UInteractSystem& InteractSystem)
	{
	}

	UFUNCTION()
	void RemoveFromAbilitySystem(UInteractSystem& InteractSystem)
	{
		InteractSystem.RemoveModifier(AttributeName, this, ID);
	}
};