class ASupporterGun : ACompanion
{
	UPROPERTY(BlueprintReadWrite, Category = Bullet)
	TSubclassOf<ABullet> BulletTemplate;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem MuzzleVFX;

	// APostProcessVolume PPV;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		// Super::ConstructionScript();
		RightHandWp.AttachTo(CompanionSkeleton, n"RightGun");
		// PPV = Cast<APostProcessVolume>(Gameplay::GetActorOfClass(APostProcessVolume));
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		ABowling pawn = Cast<ABowling>(OtherActor);
		if (pawn != nullptr)
		{
			// Attack();
			System::SetTimer(this, n"Attack", 0.15f, true);
			AnimateInst.Montage_Play(AttackAnim);
		}
	}

	UFUNCTION()
	void Attack()
	{
		// ABullet SpawnedActor = Cast<ABullet>()
		Niagara::SpawnSystemAtLocation(MuzzleVFX, RightHandWp.GetSocketLocation(n"Muzzle"), FRotator(0, 180, 0));
		SpawnActor(BulletTemplate, RightHandWp.GetSocketLocation(n"Muzzle"), CompanionSkeleton.GetWorldRotation());

		Gameplay::PlayWorldCameraShake(ShakeStyle, GetActorLocation(), 0, 10000, 0, true);
		// PPV.bEnabled = true;
		// System::SetTimer(this, n"DisableEffect", 0.05f, false);

		AtksLeft--;
		if (AtksLeft <= 0)
		{
			// NiagaraComp =
			System::ClearTimer(this, "Attack");
			AtksLeft = NumberOfAtks;
		}
	}

	UFUNCTION()
	void DisableEffect()
	{
		// PPV.bEnabled = false;
	}
}
