class UAttackHitNotify : UAnimNotify
{
	/// Called when the animation notify is triggered. Checks if the mesh component's
	/// owner is a zombie, and if so, calls the zombie's AttackHit() function.
	UFUNCTION(BlueprintOverride)
	bool Notify(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation,
				FAnimNotifyEventReference EventReference) const
	{
		AZombie zomb = Cast<AZombie>(MeshComp.GetOwner());
		if (zomb != nullptr)
		{
			zomb.AttackHit();
		}
		return true;
	}
}
