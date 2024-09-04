class URewardOpenNotify : UAnimNotify
{
	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	/// Triggered from animation
	UFUNCTION(BlueprintOverride)
	bool Notify(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation, FAnimNotifyEventReference EventReference) const
	{
		return true;
	}
}
