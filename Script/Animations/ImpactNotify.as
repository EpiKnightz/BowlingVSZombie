class UImpactNotify : UAnimNotify
{
	/// Triggered from animation
	UFUNCTION(BlueprintOverride)
	bool Notify(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation, FAnimNotifyEventReference EventReference) const
	{
		if (IsValid(MeshComp) && IsValid(MeshComp.GetOwner()))
		{
			auto CinematicResponse = UCinematicResponseComponent::Get(MeshComp.GetOwner());
			if (IsValid(CinematicResponse))
			{
				CinematicResponse.NotifyImpact();
				return true;
			}
		}
		return false;
	}
}
