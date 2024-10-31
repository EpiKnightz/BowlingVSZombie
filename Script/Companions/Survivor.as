const float SURVIVOR_Y_LIMIT = 400;
const float SURVIVOR_MAX_X = 685;
const float SURVIVOR_MIN_X = -1200;
class ASurvivor : AHumanlite
{
	default Collider.SetCollisionProfileName(n"Companion");
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;
	default BodyMesh.SetRelativeLocationAndRotation(FVector(0, 0, -50), FRotator(0, 90, 0));

	// Static mesh component
	UWeapon Weapon;

	UCustomAnimInst AnimateInst;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent WorldWidget;
	UUIRankText RankText;

	UPROPERTY(DefaultComponent)
	ULiteAbilitySystem AbilitySystem;

	UPROPERTY(DefaultComponent)
	UAttackResponseComponent AttackResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Survivor;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	UPROPERTY(DefaultComponent)
	UMovementResponseComponent MovementResponseComponent;

	UPROPERTY(DefaultComponent)
	URankResponseComponent RankResponseComponent;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default MovementComp.bShouldBounce = true;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.bConstrainToPlane = true;
	default MovementComp.PlaneConstraintAxisSetting = EPlaneConstraintAxisSetting::UseGlobalPhysicsSetting;
	default MovementComp.PlaneConstraintNormal = FVector(0, 0, 1);
	default MovementComp.AutoActivate = true;
	default MovementComp.Bounciness = 0.8;

	private EDragState DragState;

	FTagAbilitySystemDelegate DRegisterAbilities;
	FVoidDelegate DRankUpTarget;
	FTagInt2SurvivorDataDelegate DGetRankedSurvivorData;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);

		AnimateInst = Cast<UCustomAnimInst>(BodyMesh.GetAnimInstance());

		AbilitySystem.RegisterAttrSet(UPrimaryAttrSet);
		AbilitySystem.RegisterAttrSet(UAttackAttrSet);
		AbilitySystem.RegisterAttrSet(UMovementAttrSet);
		AbilitySystem.SetBaseValue(n"Accel", 0);

		AttackResponseComponent.Initialize(AbilitySystem);
		TargetResponseComponent.Initialize(AbilitySystem);
		DamageResponseComponent.Initialize(AbilitySystem);
		MovementResponseComponent.Initialize(AbilitySystem);
		MovementResponseComponent.StopLifeTime = 0;
		MovementResponseComponent.EOnPostAddForce.AddUFunction(this, n"OnPostAddForce");

		RankResponseComponent.EOnRankUp.AddUFunction(this, n"OnRankUp");
		RankText = Cast<UUIRankText>(WorldWidget.GetWidget());
		if (!IsValid(RankText))
		{
			PrintError("RankText is invalid");
		}
		else
		{
			RankResponseComponent.EOnRankUp.AddUFunction(RankText, n"SetRankText");
		}

		auto AbilitiesManager = Gameplay::GetActorOfClass(AAbilitiesManager);
		if (IsValid(AbilitiesManager))
		{
			DRegisterAbilities.BindUFunction(AbilitiesManager, n"RegisterAbilities");
		}
	}

	UFUNCTION()
	private void OnPostAddForce()
	{
	}

	UFUNCTION()
	void SetData(FSurvivorDT DataRow)
	{
		TargetResponseComponent.SetID(DataRow.SurvivorID);
		TMap<FName, float32> Data;
		Data.Add(n"MaxHP", DataRow.HP);
		Data.Add(n"Attack", DataRow.Atk);
		Data.Add(n"MoveSpeed", DataRow.Speed);
		Data.Add(n"Accel", DataRow.Accel);
		Data.Add(n"AttackCooldown", DataRow.AttackCooldown);
		Data.Add(n"Bounciness", DataRow.Bounciness);

		AbilitySystem.ImportData(Data);

		ChangeWeapon(DataRow.WeaponTag);
		SetMeshes(DataRow.BodyMesh, DataRow.HeadMesh, DataRow.AccessoryMesh);

		SetBodyScale(DataRow.BodyScale);
		SetHeadScale(DataRow.HeadScale);

		Collider.OnComponentHit.AddUFunction(this, n"OnHit");

		AttackResponseComponent.DGetAttackLocation.BindUFunction(this, n"GetAttackLocation");
		AttackResponseComponent.DGetAttackRotation.BindUFunction(this, n"GetAttackRotation");
		AttackResponseComponent.EOnAnimHitNotify.AddUFunction(Weapon, n"AttackHitCue");
		AttackResponseComponent.DGetSocketLocation.BindUFunction(this, n"GetSocketLocation");
		DamageResponseComponent.EOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.EOnDeadCue.AddUFunction(this, n"DeadCue");

		AddAbilities(DataRow.AbilitiesTags);
	}

	void ChangeWeapon(FGameplayTag WeaponTag)
	{
		if (IsValid(Weapon))
		{
			Weapon.ForceDestroyComponent();
			Weapon = nullptr;
		}
		AWeaponsManager WeaponsManager = Gameplay::GetActorOfClass(AWeaponsManager);
		if (IsValid(WeaponsManager))
		{
			WeaponsManager.CreateWeaponFromTag(WeaponTag, this, Weapon);
		}
	}

	void AddAbility(FGameplayTag AbilityTag)
	{
		AddAbilities(AbilityTag.GetSingleTagContainer());
	}

	void AddAbilities(FGameplayTagContainer AbilityTags)
	{
		DRegisterAbilities.ExecuteIfBound(AbilityTags, AbilitySystem);
	}

	UFUNCTION()
	void OnRankUp(int NewRank)
	{
		PopUpAnimation(1 + 0.15 * (NewRank - 1));
		SetData(DGetRankedSurvivorData.Execute(TargetResponseComponent.TargetID, NewRank));
		DamageResponseComponent.EOnEnterTheBattlefield.Broadcast();
	}

	void RegisterDragEvents(bool bEnabled = true)
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		if (bEnabled)
		{
			DragState = EDragState::Dragging;
			Collider.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Enemy, ECollisionResponse::ECR_Ignore);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Companion, ECollisionResponse::ECR_Overlap);
			Pawn.EOnTouchHold.AddUFunction(this, n"OnDragged");
			Pawn.EOnTouchReleased.AddUFunction(this, n"OnDragReleased");
		}
		else
		{
			DragState = EDragState::None;
			Pawn.EOnTouchHold.UnbindObject(this);
			Pawn.EOnTouchReleased.UnbindObject(this);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Enemy, ECollisionResponse::ECR_Block);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Companion, ECollisionResponse::ECR_Block);
		}
		Pawn.DSetBowlingAimable.ExecuteIfBound(!bEnabled);
	}

	UFUNCTION()
	private void OnDragged(AActor OtherActor, FVector Vector)
	{
		SetActorLocation(FVector(Vector.X, Vector.Y, GetActorLocation().Z));
		if (DragState == EDragState::Dragging)
		{
			if (Vector.Y > SURVIVOR_Y_LIMIT
				|| Vector.Y < -SURVIVOR_Y_LIMIT
				|| Vector.X > SURVIVOR_MAX_X
				|| Vector.X < SURVIVOR_MIN_X)
			{
				ColorOverlay.ChangeOverlayColor(FLinearColor::Red, true);
			}
			else
			{
				ColorOverlay.ChangeOverlayColor(FLinearColor::Green, true);
			}
		}
	}

	UFUNCTION()
	private void OnDragReleased(AActor OtherActor, FVector Vector)
	{
		Gameplay::SetGlobalTimeDilation(1);
		if (!DRankUpTarget.IsBound())
		{
			Collider.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
			SetActorLocation(FVector(
				Math::Clamp(GetActorLocation().X, SURVIVOR_MIN_X, SURVIVOR_MAX_X),
				Math::Clamp(GetActorLocation().Y, -SURVIVOR_Y_LIMIT, SURVIVOR_Y_LIMIT),
				60));
			ColorOverlay.ResetOverlayColor();
			PopUpAnimation();
			RegisterDragEvents(false);
			EnableAttack();
			DamageResponseComponent.EOnEnterTheBattlefield.Broadcast();
		}
		else
		{
			DRankUpTarget.Execute();
			RegisterDragEvents(false);
			DestroyActor();
		}
	}

	UFUNCTION()
	void EnableAttack(bool bEnabled = true)
	{
		if (bEnabled)
		{
			AttackResponseComponent.DPlayAttackAnim.BindUFunction(this, n"PlayAttackAnim");
		}
		else
		{
			AttackResponseComponent.DPlayAttackAnim.Clear();
		}
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		UTargetResponseComponent OtherTargetComp = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(OtherTargetComp))
		{
			if (OtherTargetComp.TargetID == TargetResponseComponent.TargetID)
			{
				URankResponseComponent OtherRankComp = URankResponseComponent::Get(OtherActor);
				if (IsValid(OtherRankComp))
				{
					if (OtherRankComp.IsMaxRank() || RankResponseComponent.IsMaxRank())
					{
						ColorOverlay.ChangeOverlayColor(FLinearColor::Red, true);
					}
					else
					{
						DRankUpTarget.BindUFunction(OtherRankComp, n"RankUp");
						ColorOverlay.ChangeOverlayColor(FLinearColor::Yellow, true);
					}
					DragState = EDragState::Overlapping;
				}
			}
		}
		OnHit(nullptr, OtherActor, nullptr, FVector::ZeroVector, FHitResult());
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		UTargetResponseComponent OtherTargetComp = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(OtherTargetComp))
		{
			if (OtherTargetComp.TargetID == TargetResponseComponent.TargetID)
			{
				ColorOverlay.ResetOverlayColor();
				DRankUpTarget.Clear();
				DragState = EDragState::Dragging;
			}
		}
	}

	UFUNCTION()
	private void OnHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		AttackResponseComponent.EOnBeginOverlapEvent.Broadcast(OtherActor);
	}

	////////////////////////////
	// Visual Cues
	////////////////////////////

	UFUNCTION()
	void PlayAttackAnim()
	{
		if (!DamageResponseComponent.bIsDead)
		{
			AnimateInst.Montage_Play(Weapon.AttackAnim);
		}
	}

	void PlayDeadAnim(int AnimIndex) override
	{
		AnimateInst.Montage_Stop(0, AnimateInst.GetCurrentActiveMontage());
		AnimateInst.StopSlotAnimation();
		System::SetTimer(this, n"GoingDown", AnimateInst.Montage_Play(DeadAnims[AnimIndex], 1), false);
	}

	UFUNCTION()
	private void GoingDown()
	{
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(GetActorLocation().Z, -80.f, 2.5f, EFCEase::Linear);
		FloatTween.ApplyEasing.AddUFunction(this, n"SetZLocation");
		FloatTween.OnComplete.AddUFunction(this, n"K2_DestroyActor");
		FloatTween.Start();
	}

	UFUNCTION()
	void PopUpAnimation(float FinalScale = 1)
	{
		if (IsValid(FloatTween) && FloatTween.IsValid())
		{
			FloatTween.Stop();
			FloatTween.ApplyEasing.Clear();
		}
		FloatTween = UFCTweenBPActionFloat::TweenFloat(0.1, FinalScale, 0.5f, EFCEase::OutElastic);
		FloatTween.ApplyEasing.AddUFunction(this, n"SetScaleFloat");
		FloatTween.Start();
	}

	UFUNCTION()
	void SetScaleFloat(float32 Scale)
	{
		BodyMesh.SetRelativeScale3D(FVector((Scale)));
	}

	void ResetTransform()
	{
		SetActorLocationAndRotation(FVector(0, 0, 50), FRotator::ZeroRotator);
		ResetTempScale();
	}

	UFUNCTION()
	void SetZLocation(float32 ZChange)
	{
		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, ZChange));
	}

	////////////////////////////
	// Utilities
	////////////////////////////

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
