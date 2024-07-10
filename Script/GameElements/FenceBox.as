class UFenceBox : UBoxComponent
{
	UFCTweenBPActionFloat FloatTween;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnComponentBeginOverlap.AddUFunction(this, n"ActorBeginOverlap");
	}

	UFUNCTION()
	private void ActorBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(0, 1, 0.125, EFCEase::OutElastic);
		FloatTween.bUYoyo = true;
		FloatTween.ApplyEasing.AddUFunction(this, n"Shake");
		FloatTween.Start();
	}

	UFUNCTION()
	void Shake(float32 Change)
	{
		Owner.SetActorRotation(FRotator(0, 0, Change * WorldScale.Y));
	}
};