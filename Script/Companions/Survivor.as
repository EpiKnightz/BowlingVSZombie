const float SURVIVOR_Y_LIMIT = 400;
class ASurvivor : AHumanlite
{
	default Collider.SetCollisionProfileName(n"Companion");
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;
	default BodyMesh.SetRelativeLocationAndRotation(FVector(0, 0, -50), FRotator(0, 90, 0));

	UCustomAnimInst AnimateInst;
	UFCTweenBPActionFloat FloatTween;

	UPROPERTY(DefaultComponent)
	ULiteAbilitySystem AbilitySystem;

	UPROPERTY(DefaultComponent)
	UAttackResponseComponent AttackResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Survivor;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	// Static mesh component
	UWeapon Weapon;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);

		AnimateInst = Cast<UCustomAnimInst>(BodyMesh.GetAnimInstance());

		AbilitySystem.RegisterAttrSet(UPrimaryAttrSet);
		AbilitySystem.RegisterAttrSet(UAttackAttrSet);

		AttackResponseComponent.Initialize(AbilitySystem);
		TargetResponseComponent.Initialize(AbilitySystem);
		DamageResponseComponent.Initialize(AbilitySystem);
		// Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
	}

	UFUNCTION()
	void SetData(FSurvivorDT Data)
	{
		AWeaponsManager WeaponsManager = Gameplay::GetActorOfClass(AWeaponsManager);
		if (IsValid(WeaponsManager))
		{
			WeaponsManager.CreateWeapon(Data.WeaponTag, this, Weapon);
		}

		HeadMesh.SetSkeletalMeshAsset(Data.HeadMesh);
		BodyMesh.SetSkeletalMeshAsset(Data.BodyMesh);
		AccessoryMesh.SetSkeletalMeshAsset(Data.AccessoryMesh);

		SetBodyScale(Data.BodyScale);
		SetHeadScale(Data.HeadScale);

		Collider.OnComponentHit.AddUFunction(this, n"OnHit");

		AttackResponseComponent.DGetAttackLocation.BindUFunction(this, n"GetAttackLocation");
		AttackResponseComponent.DGetAttackRotation.BindUFunction(this, n"GetAttackRotation");
		AttackResponseComponent.EOnAttackHitCue.AddUFunction(Weapon, n"AttackHitCue");
		AttackResponseComponent.DPlayAttackAnim.BindUFunction(this, n"PlayAttackAnim");
		AttackResponseComponent.DGetSocketLocation.BindUFunction(this, n"GetSocketLocation");

		DamageResponseComponent.EOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.EOnDeadCue.AddUFunction(this, n"DeadCue");

		Gameplay::GetActorOfClass(AAbilitiesManager)
			.RegisterAbilities(Data.AbilitiesTags, AbilitySystem);
	}

	void ResetTransform()
	{
		SetActorLocationAndRotation(FVector(0, 0, 50), FRotator::ZeroRotator);
		SetActorScale3D(FVector::OneVector);
	}

	void RegisterDragEvents(bool bEnabled = true)
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		if (bEnabled)
		{
			Pawn.EOnTouchHold.AddUFunction(this, n"OnDragged");
			Pawn.EOnTouchReleased.AddUFunction(this, n"OnDragReleased");
		}
		else
		{
			Pawn.EOnTouchHold.UnbindObject(this);
			Pawn.EOnTouchReleased.UnbindObject(this);
		}
	}

	UFUNCTION()
	private void OnDragged(AActor OtherActor, FVector Vector)
	{
		SetActorLocation(FVector(Vector.X, Vector.Y, GetActorLocation().Z));
		if (Vector.Y > SURVIVOR_Y_LIMIT || Vector.Y < -SURVIVOR_Y_LIMIT)
		{
			ChangeOverlayColor(FLinearColor::Red);
		}
		else
		{
			ChangeOverlayColor(FLinearColor::Green);
		}
	}

	UFUNCTION()
	private void OnDragReleased(AActor OtherActor, FVector Vector)
	{
		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, 50));
		Collider.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		ResetOverlayColor();
		PopUpAnimation();
		RegisterDragEvents(false);
	}

	UFUNCTION()
	void PopUpAnimation()
	{
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(0.1, 1, 0.5f, EFCEase::OutElastic);
		FloatTween.ApplyEasing.AddUFunction(this, n"SetScaleFloat");
		FloatTween.Start();
	}

	UFUNCTION()
	void SetScaleFloat(float32 Scale)
	{
		SetActorScale3D(FVector(Scale));
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		OnHit(nullptr, OtherActor, nullptr, FVector::ZeroVector, FHitResult());
	}

	UFUNCTION()
	private void OnHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		AttackResponseComponent.EOnBeginOverlapEvent.Broadcast(OtherActor);
	}

	UFUNCTION()
	void PlayAttackAnim()
	{
		AnimateInst.Montage_Play(Weapon.AttackAnim);
	}

	UFUNCTION()
	FVector GetSocketLocation(FName InSocketName)
	{
		return BodyMesh.GetSocketLocation(InSocketName);
	}

	UFUNCTION()
	FVector GetAttackLocation()
	{
		return Weapon.GetSocketLocation(n"Muzzle");
	}

	UFUNCTION()
	FRotator GetAttackRotation()
	{
		FRotator Result = BodyMesh.GetWorldRotation();
		Result.XRoll = 0;
		Result.YPitch = 0;
		return Result;
	}
}
