class AFocusTracker : AActor
{
	FVoidEvent EOnSequenceFinished;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent FocusTarget;

	UPROPERTY(DefaultComponent, Attach = FocusTarget)
	USceneComponent ExtraTarget;

	UFUNCTION(BlueprintCallable, Category = "Script Actor")
	void OnSequenceFinished()
	{
		EOnSequenceFinished.Broadcast();
	}

	UFUNCTION()
	void SetZLocation(float32 ZChange)
	{
		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, ZChange));
	}
};