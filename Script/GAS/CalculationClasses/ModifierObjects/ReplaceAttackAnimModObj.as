class UReplaceAttackAnimObj : UModifierObject
{
	UPROPERTY()
	TArray<UAnimMontage> NewAttackAnim;

	void AddToAbilitySystem(UInteractSystem& InteractSystem) override
	{
		AZombie Zomb = Cast<AZombie>(InteractSystem.Owner);
		if (IsValid(Zomb))
		{
			Zomb.ReplaceAnimation(NewAttackAnim);
		}
	}
}