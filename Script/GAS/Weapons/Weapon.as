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

	protected UColorOverlay ColorOverlay;
	protected FLinearColor CachedOverlayColor = FLinearColor::Transparent;
	protected AActor Target;
	// bool bIsRightHand = true;

	FActorDelegate DOnTargetChosen;
	FVoidEvent EOnDragReleased;

	// APostProcessVolume PPV;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}

	// Only called from child classes
	// This is because different weapons have different sockets
	void Setup(bool RightHand = true)
	{
	}

	protected void SetupInner(FString AttachLocation, bool bIsRightHand = true)
	{
		// PPV = Gameplay::GetActorOfClass(APostProcessVolume);
		auto CompanionSkeleton = USkeletalMeshComponent::Get(Owner);
		FName HandName = bIsRightHand ? FName("Right" + AttachLocation) : FName("Left" + AttachLocation);
		if (IsValid(CompanionSkeleton))
		{
			AttachTo(CompanionSkeleton, HandName);
		}

		ColorOverlay = NewObject(this, UColorOverlay);
		ColorOverlay.SetupDynamicMaterial(GetMaterial(0));
		SetMaterial(0, ColorOverlay.DynamicMat);
	}

	UFUNCTION()
	void ResetTransform()
	{
		GetOwner().SetActorLocationAndRotation(FVector(0, 0, 50), FRotator(0, 90, 90));
		GetOwner().SetActorScale3D(FVector::OneVector * 2);
	}

	void RegisterDragEvents(bool bEnabled = true)
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		if (bEnabled)
		{
			Target = nullptr;
			ColorOverlay.ChangeOverlayColor(FLinearColor::Red);
			SetCollisionProfileName(n"Weapon");
			OnComponentBeginOverlap.AddUFunction(this, n"OnOverlap");
			OnComponentEndOverlap.AddUFunction(this, n"OnOverlapEnd");
			Pawn.EOnTouchHold.AddUFunction(this, n"OnDragged");
			Pawn.EOnHoldReleased.AddUFunction(this, n"OnDragReleased");
		}
		else
		{
			Pawn.EOnTouchHold.UnbindObject(this);
			Pawn.EOnHoldReleased.UnbindObject(this);
			OnComponentBeginOverlap.UnbindObject(this);
			OnComponentEndOverlap.UnbindObject(this);
			SetCollisionEnabled(ECollisionEnabled::NoCollision);
			OnComponentBeginOverlap.Clear();
			OnComponentEndOverlap.Clear();
		}
		Pawn.DSetBowlingAimable.ExecuteIfBound(!bEnabled);
	}

	UFUNCTION()
	private void OnOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		Target = OtherActor;
		ColorOverlay.ChangeOverlayColor(FLinearColor::Green);
	}

	UFUNCTION()
	private void OnOverlapEnd(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex)
	{
		Target = nullptr;
		ColorOverlay.ChangeOverlayColor(FLinearColor::Red);
	}

	UFUNCTION()
	private void OnDragged(AActor OtherActor, FVector Vector)
	{
		GetOwner().SetActorLocation(FVector(Vector.X, Vector.Y, GetOwner().GetActorLocation().Z));
	}

	UFUNCTION()
	private void OnDragReleased(AActor OtherActor, FVector Vector)
	{
		if (IsValid(Target))
		{
			Gameplay::SetGlobalTimeDilation(1);
			RegisterDragEvents(false);
			DOnTargetChosen.ExecuteIfBound(Target);
			EOnDragReleased.Broadcast();
			GetOwner().DestroyActor();
		}
	}

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

		auto AbilitySys = ULiteAbilitySystem::Get(Owner);
		if (IsValid(AbilitySys))
		{
			Gameplay::GetActorOfClass(AAbilitiesManager)
				.RegisterAbilities(Data.DefaultAttackAbility.GetSingleTagContainer(), AbilitySys);
			AbilitySys.SetBaseValue(n"Attack", Data.Attack);
		}
	}

	UFUNCTION()
	void DisableEffect()
	{
		// PPV.Settings.WeightedBlendables.Array[1].Weight = 0;
	}
};