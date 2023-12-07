delegate void FObstacleDestroyedDelegate();
class AObstacle : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent ObstacleMesh;
	default ObstacleMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(BlueprintReadWrite)
	int HP = 200;

	FObstacleDestroyedDelegate ObstDestrEvent;

	UFCTweenBPActionFloat FloatTween;
	// FRotator OriginalRot;
	FVector OriginalLoc;
	bool bIsDestroyed = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// OriginalRot = ObstacleMesh.GetRelativeRotation();
		OriginalLoc = GetActorLocation();
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		AZombie zomb = Cast<AZombie>(OtherActor);
		if (zomb != nullptr)
		{
			zomb.AttackHitEvent.BindUFunction(this, n"AttackHit");
			ObstDestrEvent.BindUFunction(zomb, n"StopAttacking");
		}
	}

	UFUNCTION(BlueprintEvent)
	void AttackHit()
	{
		if (!bIsDestroyed)
		{
			if (UpdateHP(-100) > 0)
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
		}
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
			ObstDestrEvent.ExecuteIfBound();
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			if (FloatTween != nullptr)
			{
				FloatTween.Stop();
				FloatTween.ApplyEasing.Clear();
			}
			FloatTween = UFCTweenBPActionFloat::TweenFloat(-10.f, -120.f, 2.f, EFCEase::InExpo);
			FloatTween.ApplyEasing.AddUFunction(this, n"GoingDown");
			FloatTween.OnComplete.AddUFunction(this, n"Dead");
			FloatTween.Start();
		}
		return HP;
	}

	UFUNCTION()
	void GoingDown(float32 Change)
	{
		SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, Change));
	}

	UFUNCTION()
	void Dead()
	{
		DestroyActor();
	}
}
