class ACompanionManager : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}
};