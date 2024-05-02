class AZone : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;
	default Collider.SetCollisionEnabled(ECollisionEnabled::QueryOnly);

	UAngelscriptAbilitySystemComponent test;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		// test.ab
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
	}
};