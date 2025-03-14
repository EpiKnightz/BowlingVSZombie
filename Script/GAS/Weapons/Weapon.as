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

	FActorDelegate DOnTargetChosen;
	FVoidEvent EOnDragReleased;

	int BasicAttackID = -1;

	// APostProcessVolume PPV;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}

	// Only called from child classes
	// This is because different weapons have different sockets
	void Setup(bool MainHand = true)
	{
	}

	protected void SetupInner(FString AttachLocation, bool bIsMainHand = true)
	{
		// PPV = Gameplay::GetActorOfClass(APostProcessVolume);
		auto SkeletonMesh = USkeletalMeshComponent::Get(Owner);
		FName HandName = bIsMainHand ? FName("Right" + AttachLocation) : FName("Left" + AttachLocation);
		if (IsValid(SkeletonMesh))
		{
			AttachTo(SkeletonMesh, HandName);
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
	void SetData(FWeaponDT Data, bool bIsMainWeapon = true)
	{
		StaticMesh = Data.WeaponMesh;

		if (bIsMainWeapon)
		{
			ShakeStyle = Data.ShakeStyle;
			WeaponVFX = Data.WeaponVFX;
			AttackAnim = Data.AttackAnim;

			auto AbilitySys = ULiteAbilitySystem::Get(Owner);
			if (IsValid(AbilitySys))
			{
				// IMPORTANT: Only the basic attack id is saved. Don't remove other ids
				BasicAttackID = Gameplay::GetActorOfClass(AAbilitiesManager)
									.RegisterAbilitiesFirstID(Data.WeaponAbilities, AbilitySys);

				// 18-2-25: I decided that everytime a weapon is equipped, the attack value is added to the base value
				// Still considering if using modifier or straight up adding is better
				UAdditiveMod WeaponAtkMod = NewObject(this, UAdditiveMod);
				WeaponAtkMod.SetupOnce(1, Data.Attack);
				AbilitySys.AddModifier(AttackAttrSet::Attack, WeaponAtkMod);
				AbilitySys.AddGameplayTags(Data.EffectTags);

				AbilitySys.SetBaseValue(AttackAttrSet::AttackRange, Data.AttackRange);
			}
		}
	}

	UFUNCTION()
	void RemoveWeaponAbility()
	{
		if (BasicAttackID != -1)
		{
			auto AbilitySys = ULiteAbilitySystem::Get(Owner);
			if (IsValid(AbilitySys))
			{
				// 	AbilitySys.RemoveModifier(AttackAttrSet::Attack, this, 1);
				AbilitySys.DeregAbility(BasicAttackID);
			}
		}
	}

	UFUNCTION()
	void DisableEffect()
	{
		// PPV.Settings.WeightedBlendables.Array[1].Weight = 0;
	}
};