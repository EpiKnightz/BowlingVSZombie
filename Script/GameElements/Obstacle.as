class AObstacle : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent ObstacleMesh;
	default ObstacleMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	// UPROPERTY(DefaultComponent, Attach = Collider)
	// UNiagaraComponent NiagaraComp;

	// UPROPERTY(BlueprintReadWrite)
	// int BaseHP = 200;

	// float HP;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem BrokenVFX;

	UPROPERTY(BlueprintReadWrite, Category = Mesh)
	TArray<UStaticMesh> BrokenMesh;

	FVoidEvent EOnObstDestr;

	UFCTweenBPActionFloat FloatTween;
	// FRotator OriginalRot;
	FVector OriginalLoc;
	bool bIsDestroyed = false;

	UPROPERTY(DefaultComponent)
	UAbilitySystem AbilitySystem;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// OriginalRot = ObstacleMesh.GetRelativeRotation();
		OriginalLoc = GetActorLocation();

		AbilitySystem.RegisterAttrSet(UPrimaryAttrSet);
		AbilitySystem.Initialize(n"MaxHp", 200);
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
	void AttackHit(float Damage)
	{
		if (!bIsDestroyed)
		{
			if (TakeDamage(Damage))
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

	UFUNCTION()
	bool CheckIsAlive()
	{
		if (AbilitySystem.GetCurrentValue(n"HP") <= 0)
		{
			DeadEffect();
			return false;
		}
		else
		{
			return true;
		}
	}

	UFUNCTION()
	bool TakeDamage(float Damage)
	{
		AbilitySystem.SetCurrentValue(n"Damage", Damage);
		AbilitySystem.Calculate(n"Damage");
		return CheckIsAlive();
	}

	bool UpdateHP(float Change)
	{
		float HP = AbilitySystem.GetCurrentValue(n"HP");
		if (HP > 150 && (HP - Change) <= 150)
		{
			VisualChange(0);
		}
		else if (HP > 100 && (HP - Change) <= 100)
		{
			VisualChange(1);
		}
		else if (HP > 50 && (HP - Change) <= 50)
		{
			VisualChange(2);
		}

		HP -= Change;
		if (HP <= 0 && !bIsDestroyed)
		{

			return false;
		}
		return true;
	}

	UFUNCTION()
	void DeadEffect()
	{
		bIsDestroyed = true;
		EOnObstDestr.Broadcast();
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		if (FloatTween != nullptr)
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(0, -120.f, 2.f, EFCEase::InQuart);
		FloatTween.ApplyEasing.AddUFunction(this, n"GoingDown");
		FloatTween.OnComplete.AddUFunction(this, n"Dead");
		FloatTween.Start();
	}

	UFUNCTION()
	void VisualChange(int ChangeIdx)
	{
		ObstacleMesh.StaticMesh = BrokenMesh[ChangeIdx];
		ObstacleMesh.SetRelativeScale3D(FVector(1, 1, 0.9 - ChangeIdx * 0.15));
		Niagara::SpawnSystemAtLocation(BrokenVFX, GetActorLocation() + FVector(0, 0, 40 - ChangeIdx * 10));
	}

	UFUNCTION()
	void GoingDown(float32 Change)
	{
		SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, OriginalLoc.Z + Change));
	}

	UFUNCTION()
	void Dead()
	{
		DestroyActor();
	}
}
