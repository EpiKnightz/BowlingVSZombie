class APowerUp : ACollectible
{
	FStatusDT StatusData;

	UFUNCTION()
	void Init(FStatusDT iData)
	{
		StatusData = iData;
	}

	void OnCollectibleCollected(AActor OtherActor) override
	{
		UCooldownComponent::GetOrCreate(OtherActor, n"CooldownComponent").Init(StatusData);
	}
};