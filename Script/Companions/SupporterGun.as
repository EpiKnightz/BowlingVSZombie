class ASupporterGun : ASurvivor
{
	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem MuzzleVFX;

	// APostProcessVolume PPV;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		RightHandWp.AttachTo(CompanionSkeleton, n"RightGun");
		// PPV = Cast<APostProcessVolume>(Gameplay::GetActorOfClass(APostProcessVolume));
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		AttackResponseComponent.DGetAttackLocation.BindUFunction(this, n"GetAttackLocation");
		AttackResponseComponent.DGetAttackRotation.BindUFunction(this, n"GetAttackRotation");
		AttackResponseComponent.EOnAttackHitCue.AddUFunction(this, n"AttackHitCue");
		AttackResponseComponent.DPlayAttackAnim.BindUFunction(this, n"PlayAttackAnim");
		AttackResponseComponent.DGetSocketLocation.BindUFunction(this, n"GetSocketLocation");

		AbilitySystem.RegisterAbility(UShootOnOverlapAbility);
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		AttackResponseComponent.EOnOverlapEvent.Broadcast(OtherActor);
	}

	UFUNCTION()
	void PlayAttackAnim()
	{
		AnimateInst.Montage_Play(AttackAnim);
	}

	UFUNCTION()
	FVector GetSocketLocation(FName InSocketName)
	{
		return CompanionSkeleton.GetSocketLocation(InSocketName);
	}

	UFUNCTION()
	FVector GetAttackLocation()
	{
		return RightHandWp.GetSocketLocation(n"Muzzle");
	}

	UFUNCTION()
	FRotator GetAttackRotation()
	{
		FRotator Result = CompanionSkeleton.GetWorldRotation();
		Result.XRoll = 0;
		Result.YPitch = 0;
		return Result;
	}

	UFUNCTION()
	void AttackHitCue()
	{
		Niagara::SpawnSystemAtLocation(MuzzleVFX, RightHandWp.GetSocketLocation(n"Muzzle"), FRotator(0, 180, 0));
		Gameplay::PlayWorldCameraShake(ShakeStyle, GetActorLocation(), 0, 10000, 0, true);
		// PPV.bEnabled = true;
		// System::SetTimer(this, n"DisableEffect", 0.05f, false);
	}

	UFUNCTION()
	void DisableEffect()
	{
		// PPV.bEnabled = false;
	}
}
