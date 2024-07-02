class UWeapon : UStaticMeshComponent
{
	// Weapon tag
	//  Generate it like the status system
	default CollisionEnabled = ECollisionEnabled::NoCollision;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem WeaponVFX;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage AttackAnim;

	// APostProcessVolume PPV;

	void Setup()
	{
	}

	void SetupChild(FName AttachLocation)
	{
		// PPV = Gameplay::GetActorOfClass(APostProcessVolume);
		auto CompanionSkeleton = USkeletalMeshComponent::Get(Owner);
		if (IsValid(CompanionSkeleton))
		{
			AttachTo(CompanionSkeleton, AttachLocation);
		}
	}

	// TODO: Need to add lots of Muzzle socket to the weapons

	UFUNCTION()
	void AttackHitCue()
	{
		if (IsValid(ShakeStyle))
		{
			Gameplay::PlayWorldCameraShake(ShakeStyle, GetWorldLocation(), 0, 10000, 0, true);
		}
		// PPV.Settings.WeightedBlendables.Array[1].Weight = 1;
		// System::SetTimer(this, n"DisableEffect", 0.035f, false);
	}

	UFUNCTION()
	void SpawnAtSocket(FName InSocketName)
	{
		Niagara::SpawnSystemAtLocation(WeaponVFX, GetSocketLocation(InSocketName), FRotator(0, 180, 0));
	}

	UFUNCTION()
	void SpawnAtLocation(FVector Location)
	{
		Niagara::SpawnSystemAtLocation(WeaponVFX, Location, FRotator(0, 180, 0));
	}

	UFUNCTION()
	void SetData(FWeaponDT Data)
	{
		StaticMesh = Data.WeaponMesh;
		ShakeStyle = Data.ShakeStyle;
		WeaponVFX = Data.WeaponVFX;
		AttackAnim = Data.AttackAnim;
	}

	UFUNCTION()
	void DisableEffect()
	{
		// PPV.Settings.WeightedBlendables.Array[1].Weight = 0;
	}
};