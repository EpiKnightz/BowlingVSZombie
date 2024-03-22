class APowerUp : ACollectible
{
	void OnCollectibleCollected(AActor OtherActor) override
	{
		UCooldownComponent::GetOrCreate(OtherActor, n"CooldownComponent").Init(FStatusDT());
	}
};