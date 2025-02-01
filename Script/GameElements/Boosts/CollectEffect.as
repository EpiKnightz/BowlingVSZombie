class UCollectEffect : UDataAsset
{
	UPROPERTY()
	FGameplayTagContainer EffectTags;

	void OnCollectibleCollected(AActor OtherActor)
	{
		// Need to use the data here.
		auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
		if (IsValid(StatusResponse))
		{
			StatusResponse.DOnApplyStatus.ExecuteIfBound(EffectTags);
		}
	}
};