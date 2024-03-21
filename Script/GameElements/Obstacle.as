class AObstacle : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent ObstacleMesh;
	default ObstacleMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	// UPROPERTY(DefaultComponent, Attach = Collider)
	// UNiagaraComponent NiagaraComp;

	UPROPERTY(BlueprintReadWrite)
	int BaseHP = 200;

	int HP;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem BrokenVFX;

	UPROPERTY(BlueprintReadWrite, Category = Mesh)
	TArray<UStaticMesh> BrokenMesh;

	FVoidEvent EOnObstDestr;

	UFCTweenBPActionFloat FloatTween;
	// FRotator OriginalRot;
	FVector OriginalLoc;
	bool bIsDestroyed = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// OriginalRot = ObstacleMesh.GetRelativeRotation();
		OriginalLoc = GetActorLocation();
		HP = BaseHP;
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		AZombie zomb = Cast<AZombie>(OtherActor);
		if (zomb != nullptr && !zomb.DOnAttackHit.IsBound())
		{
			zomb.DOnAttackHit.BindUFunction(this, n"AttackHit");
			EOnObstDestr.AddUFunction(zomb, n"StopAttacking");
			zomb.SetMovingLimit(GetActorLocation().X - 100);
		}
	}

	UFUNCTION(BlueprintEvent)
	void AttackHit(int Damage)
	{
		if (!bIsDestroyed)
		{
			if (UpdateHP(-Damage) > 0)
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
		if (HP > 150 && (HP + Change) <= 150)
		{
			// NiagaraComp =
			Niagara::SpawnSystemAtLocation(BrokenVFX, GetActorLocation() + FVector(0, 0, 40));
			ObstacleMesh.StaticMesh = BrokenMesh[0];
			ObstacleMesh.SetRelativeScale3D(FVector(1, 1, 0.9f));
		}
		else if (HP > 100 && (HP + Change) <= 100)
		{
			// NiagaraComp =
			Niagara::SpawnSystemAtLocation(BrokenVFX, GetActorLocation() + FVector(0, 0, 30));
			ObstacleMesh.StaticMesh = BrokenMesh[1];
			ObstacleMesh.SetRelativeScale3D(FVector(1, 1, 0.75f));
		}
		else if (HP > 50 && (HP + Change) <= 50)
		{
			// NiagaraComp =
			Niagara::SpawnSystemAtLocation(BrokenVFX, GetActorLocation() + FVector(0, 0, 20));
			ObstacleMesh.StaticMesh = BrokenMesh[2];
			ObstacleMesh.SetRelativeScale3D(FVector(1, 1, 0.5f));
		}
		HP += Change;
		if (HP <= 0 && !bIsDestroyed)
		{
			bIsDestroyed = true;
			EOnObstDestr.Broadcast();
			Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			if (FloatTween != nullptr)
			{
				FloatTween.Stop();
				FloatTween.ApplyEasing.Clear();
			}
			FloatTween = UFCTweenBPActionFloat::TweenFloat(-10.f, -120.f, 2.f, EFCEase::InQuart);
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
