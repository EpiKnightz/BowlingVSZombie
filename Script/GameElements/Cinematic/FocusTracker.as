class AFocusTracker : AActor
{
	FVoidEvent EOnSequenceFinished;
	FVoidEvent EOnZoomInFinished;
	FVoidEvent EOnTextIntroStarted;
	FVoidEvent EOnTextIntroFinished;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent FocusTarget;

	UPROPERTY(DefaultComponent, Attach = FocusTarget)
	USceneComponent ExtraTarget;

	UFUNCTION(BlueprintCallable, Category = "Script Actor")
	void OnSequenceFinished()
	{
		EOnSequenceFinished.Broadcast();
	}

	UFUNCTION(BlueprintCallable, Category = "Script Actor")
	void OnZoomInFinished()
	{
		EOnZoomInFinished.Broadcast();
	}

	UFUNCTION(BlueprintCallable, Category = "Script Actor")
	void OnTextIntroStarted()
	{
		EOnTextIntroStarted.Broadcast();
	}

	UFUNCTION(BlueprintCallable, Category = "Script Actor")
	void OnTextIntroFinished()
	{
		EOnTextIntroFinished.Broadcast();
	}

	UFUNCTION()
	void SetZLocation(float32 ZChange)
	{
		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, ZChange));
	}
};