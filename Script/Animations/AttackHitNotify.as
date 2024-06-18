class UAttackHitNotify : UAnimNotify
{
	/// Called when the animation notify is triggered. Checks if the mesh component's
	/// owner is a zombie, and if so, calls the zombie's AttackHit() function.
	UFUNCTION(BlueprintOverride)
	bool Notify(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation,
				FAnimNotifyEventReference EventReference) const
	{
		if (IsValid(MeshComp))
		{
			auto AttackResponse = UAttackResponseComponent::Get(MeshComp.GetOwner());
			if (IsValid(AttackResponse))
			{
				AttackResponse.NotifyAttackHit();
				return true;
			}
		}
		return false;
	}
}
