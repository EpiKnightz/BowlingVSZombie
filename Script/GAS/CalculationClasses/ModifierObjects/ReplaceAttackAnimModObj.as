class UReplaceAttackAnimObj : UModifierObject
{
	UPROPERTY()
	TArray<UAnimMontage> NewAttackAnim;

	void AddToAbilitySystem(ULiteAbilitySystem& AbilitySystem) override
	{
		AZombie Zomb = Cast<AZombie>(AbilitySystem.Owner);
		if (IsValid(Zomb))
		{
			Zomb.ReplaceAnimation(NewAttackAnim);
		}
	}
}