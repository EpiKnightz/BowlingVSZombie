class UDropComponent : UActorComponent
{
	UPROPERTY()
	float StartHeight = 1500;

	UPROPERTY()
	float EndHeight = 50;

	UPROPERTY()
	float Delay;

	UPROPERTY()
	float DropDuration = 1.5;

	UFCTweenBPActionFloat FloatTween;
	FVector OriginalLoc;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OriginalLoc = Owner.GetActorLocation();
		Owner.SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, StartHeight));
		if (FloatTween != nullptr)
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(StartHeight, EndHeight, DropDuration, EFCEase::OutBounce);
		FloatTween.ApplyEasing.AddUFunction(this, n"GoingDown");
		FloatTween.UDelay = Delay;
		FloatTween.Start();
	}

	UFUNCTION()
	void GoingDown(float32 Change)
	{
		Owner.SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, Change));
	}

	UFUNCTION()
	void EndEarly()
	{
		FloatTween.Stop();
		Owner.SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, EndHeight));
	}
};