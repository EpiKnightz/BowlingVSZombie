class UAttackHitNotify : UAnimNotify
{
	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	/// Triggered from animation
	UFUNCTION(BlueprintOverride)
	bool Notify(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation, FAnimNotifyEventReference EventReference) const
	{
		if (IsValid(MeshComp) && IsValid(MeshComp.GetOwner()))
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
