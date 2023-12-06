class AObstacle : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent ObstacleMesh;
	default ObstacleMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(BlueprintReadWrite)
	int HP = 200;

	UFCTweenBPActionFloat FloatTween;
	// FRotator OriginalRot;
	bool bIsDestroyed = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// OriginalRot = ObstacleMesh.GetRelativeRotation();
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		AZombie zomb = Cast<AZombie>(OtherActor);
		if (zomb != nullptr)
		{
			zomb.AttackHitEvent.BindUFunction(this, n"AttackHit");
		}
	}

	UFUNCTION(BlueprintEvent)
	void AttackHit()
	{
		if (FloatTween != nullptr)
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(0, -4.f, 0.125f, EFCEase::OutElastic);
		FloatTween.bUYoyo = true;
		FloatTween.ApplyEasing.AddUFunction(this, n"Shake");
		FloatTween.Start();
	}

	UFUNCTION()
	void Shake(float32 Change)
	{
		ObstacleMesh.SetRelativeRotation(/*OriginalRot + */ FRotator(Change, 0, 0));
	}

	int UpdateHP(int Change)
	{
		HP += Change;
		if (HP <= 0 && !bIsDestroyed)
		{
			bIsDestroyed = true;
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		}
		return HP;
	}
}
