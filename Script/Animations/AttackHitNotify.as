class UAttackHitNotify : UAnimNotify
{
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
