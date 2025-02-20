class AObstacle : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent ObstacleMesh;
	default ObstacleMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem BrokenVFX;

	UPROPERTY(BlueprintReadWrite, Category = Mesh)
	TArray<UStaticMesh> BrokenMesh;

	UFCTweenBPActionFloat FloatTween;
	FVector OriginalLoc;

	UPROPERTY(DefaultComponent)
	ULiteAbilitySystem AbilitySystem;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Obstacle;

	float OldHP;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OriginalLoc = GetActorLocation();

		AbilitySystem.RegisterAttrSet(UPrimaryAttrSet);
		AbilitySystem.Initialize(PrimaryAttrSet::MaxHP, 200);
		OldHP = AbilitySystem.GetValue(PrimaryAttrSet::HP);

		DamageResponseComponent.Initialize(AbilitySystem);
		DamageResponseComponent.EOnHitCue.AddUFunction(this, n"TakeHitCue");
		DamageResponseComponent.EOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.EOnDeadCue.AddUFunction(this, n"DeadCue");
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Visual Cues:

	UFUNCTION(BlueprintEvent)
	void TakeHitCue()
	{
		if (IsValid(FloatTween) && FloatTween.IsValid())
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

	UFUNCTION()
	void TakeDamageCue()
	{
		float NewHP = AbilitySystem.GetValue(PrimaryAttrSet::HP);
		if (OldHP > 150 && NewHP <= 150)
		{
			VisualChange(0);
		}
		else if (OldHP > 100 && NewHP <= 100)
		{
			VisualChange(1);
		}
		else if (OldHP > 50 && NewHP <= 50)
		{
			VisualChange(2);
		}
		OldHP = NewHP;
	}

	UFUNCTION()
	void VisualChange(int ChangeIdx)
	{
		ObstacleMesh.StaticMesh = BrokenMesh[ChangeIdx];
		ObstacleMesh.SetRelativeScale3D(FVector(1, 1, 0.9 - ChangeIdx * 0.15));
		Niagara::SpawnSystemAtLocation(BrokenVFX, GetActorLocation());
	}

	UFUNCTION()
	void DeadCue()
	{
		TargetResponseComponent.TargetType = ETargetType::Untargetable;
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(0, -120.f, 1.5f, EFCEase::InQuart);
		FloatTween.ApplyEasing.AddUFunction(this, n"ChangeZLocation");
		FloatTween.OnComplete.AddUFunction(this, n"Dead");
		FloatTween.Start();
	}

	UFUNCTION()
	void ChangeZLocation(float32 Change)
	{
		SetActorLocation(FVector(OriginalLoc.X, OriginalLoc.Y, OriginalLoc.Z + Change));
	}

	UFUNCTION()
	void Dead()
	{
		DestroyActor();
	}
}
