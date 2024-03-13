class ADropObject : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;
	default Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent DropMesh;

	UPROPERTY()
	bool bIsActivated = true;

	UPROPERTY()
	bool bIsDropping = false;

	UPROPERTY()
	float StartHeight = 1500;

	UPROPERTY()
	float EndHeight = -2.5;

	UPROPERTY()
	float Delay;

	UPROPERTY()
	float DropDuration = 1.5;

	UFCTweenBPActionFloat FloatTween;
	FVector OriginalLoc;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Activate(bIsActivated, bIsDropping);
	}

	UFUNCTION()
	void Activate(bool isActivated = true, bool isDropping = true)
	{
		bIsActivated = isActivated;
		bIsDropping = isDropping;
		if (bIsActivated)
		{
			ActorHiddenInGame = false;
			if (bIsDropping)
			{
				ActorTickEnabled = true;
				OriginalLoc = GetActorLocation();
				SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, StartHeight));
				if (FloatTween != nullptr)
				{
					FloatTween.Stop();
					FloatTween.ApplyEasing.Clear();
				}
				FloatTween = UFCTweenBPActionFloat::TweenFloat(StartHeight, EndHeight, DropDuration, EFCEase::OutSine);
				FloatTween.ApplyEasing.AddUFunction(this, n"GoingDown");
				FloatTween.UDelay = Delay;
				FloatTween.Start();
			}
		}
		else
		{
			ActorTickEnabled = false;
			ActorHiddenInGame = true;
		}
	}

	UFUNCTION()
	void GoingDown(float32 Change)
	{
		SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, Change));
	}
}
