const float SURVIVOR_Y_LIMIT = 400;
const float SURVIVOR_MAX_X = 685;
const float SURVIVOR_MIN_X = -1200;
class ASurvivor : AHumanlite
{
	default Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default Collider.SetCollisionProfileName(n"NoCollision");
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;
	default BodyMesh.SetRelativeLocationAndRotation(FVector(0, 0, -50), FRotator(0, 90, 0));

	// Static mesh component
	UWeapon MainWeapon;
	UWeapon OffWeapon;

	UCustomAnimInst AnimateInst;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent RankWorldWidget;
	default RankWorldWidget.SetTickMode(ETickMode::Automatic);
	UUIRankText RankText;
	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent RageWorldWidget;
	UUIRageBar RageBarWidget;

	default TargetResponseComponent.TargetType = ETargetType::Survivor;

	UPROPERTY(DefaultComponent)
	URankResponseComponent RankResponseComponent;

	UPROPERTY(DefaultComponent)
	URageResponseComponent RageResponseComponent;
	UPROPERTY(DefaultComponent)
	USkillResponseComponent SkillResponseComponent;

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
	private FGameplayTag StruckType = GameplayTags::Description;

	FTagAbilitySystemDelegate DRegisterAbilities;
	FVoidDelegate DRankUpTarget;
	FTagInt2SurvivorDataDelegate DGetRankedSurvivorData;
	FVoidEvent EOnDragReleased;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();

		InteractSystem.RegisterAttrSet(URageAttrSet);
		InteractSystem.RegisterAttrSet(USkillAttrSet);
		InteractSystem.SetBaseValue(MovementAttrSet::Accel, 0);
		InteractSystem.EOnActorTagAdded.AddUFunction(this, n"OnActorTagAdded");
		InteractSystem.EOnActorTagRemoved.AddUFunction(this, n"OnActorTagRemoved");
		InteractSystem.EOnPostCalculation.AddUFunction(this, n"OnPostCalculation");

		AttackResponseComponent.Initialize(InteractSystem);
		AttackResponseComponent.SetupAttack(n"PlayAttackAnim");
		AttackResponseComponent.EOnBeginOverlapEvent.AddUFunction(RageResponseComponent, n"OnBeginOverlap");
		TargetResponseComponent.Initialize(InteractSystem);
		DamageResponseComponent.Initialize(InteractSystem);
		MovementResponseComponent.Initialize(InteractSystem);
		MovementResponseComponent.StopLifeTime = 0;
		// MovementResponseComponent.EOnPostAddForce.AddUFunction(this, n"OnPostAddForce");

		SkillResponseComponent.Initialize(InteractSystem);

		StatusResponseComponent.Initialize(InteractSystem);
		StatusResponseComponent.DChangeOverlayColor.BindUFunction(ColorOverlay, n"ChangeOverlayColor");

		RankResponseComponent.Initialize(InteractSystem);
		RankResponseComponent.EOnRankUp.AddUFunction(this, n"OnRankUp");
		RankText = Cast<UUIRankText>(RankWorldWidget.GetWidget());
		if (!IsValid(RankText))
		{
			PrintError("RankText is invalid");
		}
		else
		{
			RankResponseComponent.EOnRankUp.AddUFunction(RankText, n"SetRankText");
		}

		RageResponseComponent.Initialize(InteractSystem);
		RageBarWidget = Cast<UUIRageBar>(RageWorldWidget.GetWidget());
		if (!IsValid(RankText))
		{
			PrintError("RageBarWidget is invalid");
		}
		else
		{
			RageWorldWidget.SetVisibility(false);
		}
		RageResponseComponent.EOnRageChange.AddUFunction(RageBarWidget, n"SetRageBar");
		RageResponseComponent.EOnRageHighlightCue.AddUFunction(RageBarWidget, n"HighlightRageBarAnim");

		auto AbilitiesManager = Gameplay::GetActorOfClass(AAbilitiesManager);
		if (IsValid(AbilitiesManager))
		{
			DRegisterAbilities.BindUFunction(AbilitiesManager, n"RegisterAbilities");
		}
	}

	UFUNCTION()
	private void OnPostCalculation(FName AttrName, float Value)
	{
		if ((AttrName == PrimaryAttrSet::Damage || AttrName == PrimaryAttrSet::HP) && Value > 0)
		{
			float HPPercentage = InteractSystem.GetValue(PrimaryAttrSet::HP) / InteractSystem.GetValue(PrimaryAttrSet::MaxHP);
			HPBarWidget.SetHPBar(HPPercentage);
		}
	}

	UFUNCTION()
	private void OnPostAddForce()
	{
	}

	UFUNCTION()
	void SetData(FSurvivorDT DataRow, bool bFirstInit = false)
	{
		TargetResponseComponent.SetID(DataRow.SurvivorID);
		TMap<FName, float32> Data;
		Data.Add(PrimaryAttrSet::MaxHP, DataRow.HP);
		Data.Add(MovementAttrSet::MoveSpeed, DataRow.Speed);
		Data.Add(MovementAttrSet::Accel, DataRow.Accel);
		Data.Add(AttackAttrSet::Attack, DataRow.Attack);
		Data.Add(AttackAttrSet::AttackCooldown, DataRow.AttackCooldown);
		Data.Add(MovementAttrSet::Bounciness, DataRow.Bounciness);
		Data.Add(RageAttrSet::InitialRage, DataRow.InitialRage);
		RageResponseComponent.AddRage(DataRow.InitialRage);
		Data.Add(RageAttrSet::RageRegen, DataRow.RageRegen);
		Data.Add(RageAttrSet::RageBonus, DataRow.RageBonus);

		InteractSystem.ImportData(Data);

		ChangeWeapon(DataRow.WeaponTag);
		SetMeshes(DataRow.BodyMesh, DataRow.HeadMesh, DataRow.AccessoryMesh);

		AnimateInst = Cast<UCustomAnimInst>(BodyMesh.GetAnimInstance());
		AnimateInst.OnMontageEnded.AddUFunction(this, n"OnMontageEnded");

		SetBodyScale(DataRow.BodyScale);
		SetHeadScale(DataRow.HeadScale);

		ChangeStruckType(DataRow.DescriptionTags.Filter(GameplayTags::Description_StruckType.GetSingleTagContainer()), bFirstInit);
		Collider.OnComponentHit.AddUFunction(this, n"OnHit");

		AttackResponseComponent.DGetAttackLocation.BindUFunction(this, n"GetAttackLocation");
		AttackResponseComponent.DGetOffhandAttackLocation.BindUFunction(this, n"GetOffhandAttackLocation");
		AttackResponseComponent.DGetAttackRotation.BindUFunction(this, n"GetAttackRotation");
		AttackResponseComponent.EOnAnimHitNotify.AddUFunction(MainWeapon, n"AttackHitCue");
		AttackResponseComponent.DGetSocketLocation.BindUFunction(this, n"GetSocketLocation");
		InteractSystem.AddGameplayTags(DataRow.EffectTags);

		DamageResponseComponent.EOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.EOnDeadCue.AddUFunction(this, n"DeadCue");

		AddAbilities(DataRow.AbilitiesTags);
	}

	UFUNCTION()
	void ChangeStruckType(FGameplayTagContainer StruckTypeTag, bool bFirstInit = false)
	{
		if (StruckTypeTag.IsValid() && StruckTypeTag.Num() == 1)
		{
			StruckType = StruckTypeTag.First();
			if (StruckType.MatchesTag(GameplayTags::Description_StruckType))
			{
				if (!bFirstInit)
				{
					SetCollisionResponse();
				}
				return;
			}
		}
		StruckType = GameplayTags::Description;
		PrintError("ChangeStruckType: invalid StruckTypeTag");
	}

	void SetCollisionResponse(bool bIgnore = false)
	{
		if (bIgnore)
		{
			Collider.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
			Collider.SetCollisionObjectType(ECollisionChannel::Survivor);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Enemy, ECollisionResponse::ECR_Ignore);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Bowling, ECollisionResponse::ECR_Ignore);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Survivor, ECollisionResponse::ECR_Overlap);
		}
		else
		{
			Collider.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
			Collider.SetCollisionProfileName(n"Survivor");
			ECollisionResponse ColResp = ECollisionResponse::ECR_Overlap;
			if (StruckType == GameplayTags::Description_StruckType_Bounce)
			{
				ColResp = ECollisionResponse::ECR_Block;
				MovementResponseComponent.SetIsAccelable(true);
				MovementResponseComponent.SetIsBouncable(true);
			}
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Enemy, ECollisionResponse::ECR_Block);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Bowling, ColResp);
			Collider.SetCollisionResponseToChannel(ECollisionChannel::Survivor, ColResp);
		}
	}

	void ChangeWeapon(FGameplayTag WeaponTag)
	{
		if (IsValid(MainWeapon))
		{
			if (WeaponTag == MainWeapon.WeaponID) // Duplicate weapon, don't need to change
			{
				return;
			}
			MainWeapon.RemoveWeaponAbility();
			MainWeapon.ForceDestroyComponent();
			MainWeapon = nullptr;
		}
		AWeaponsManager WeaponsManager = Gameplay::GetActorOfClass(AWeaponsManager);
		if (IsValid(WeaponsManager))
		{
			WeaponsManager.CreateWeaponFromTag(WeaponTag, this, MainWeapon);
		}
		if (InteractSystem.HasTag(GameplayTags::Description_Weapon_DualWield))
		{
			if (IsValid(OffWeapon))
			{
				OffWeapon.ForceDestroyComponent();
				OffWeapon = nullptr;
			}
			WeaponsManager.CreateWeaponFromTag(WeaponTag, this, OffWeapon, false);
		}
	}

	void AddAbility(FGameplayTag AbilityTag)
	{
		AddAbilities(AbilityTag.GetSingleTagContainer());
	}

	void AddAbilities(FGameplayTagContainer AbilityTags)
	{
		DRegisterAbilities.ExecuteIfBound(AbilityTags, InteractSystem);
	}

	UFUNCTION()
	void OnRankUp(int NewRank)
	{
		PopUpAnimation(1 + 0.15 * (NewRank - 1));
		SetData(DGetRankedSurvivorData.Execute(TargetResponseComponent.TargetID, NewRank));
		DamageResponseComponent.EOnEnterTheBattlefield.Broadcast();
	}

	UFUNCTION()
	void OnNewCardAdded()
	{
		DamageResponseComponent.EOnNewCardAdded.Broadcast();
	}

	void RegisterDragEvents(bool bEnabled = true)
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.DSetBowlingAimable.ExecuteIfBound(!bEnabled);
		if (bEnabled)
		{
			DragState = EDragState::Dragging;
			SetCollisionResponse(true);
			Pawn.EOnTouchHold.AddUFunction(this, n"OnDragged");
			Pawn.EOnHoldReleased.AddUFunction(this, n"OnDragReleased");
		}
		else
		{
			DragState = EDragState::None;
			Pawn.EOnTouchHold.UnbindObject(this);
			Pawn.EOnHoldReleased.UnbindObject(this);
			SetCollisionResponse();
		}
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
			// Collider.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
			SetActorLocation(FVector(
				Math::Clamp(GetActorLocation().X, SURVIVOR_MIN_X, SURVIVOR_MAX_X),
				Math::Clamp(GetActorLocation().Y, -SURVIVOR_Y_LIMIT, SURVIVOR_Y_LIMIT),
				60));
			ColorOverlay.ResetOverlayColor();
			PopUpAnimation();
			RegisterDragEvents(false);
			EnableSurvivor();
			DamageResponseComponent.EOnEnterTheBattlefield.Broadcast();
			EOnDragReleased.Broadcast();
		}
		else
		{
			DRankUpTarget.Execute();
			RegisterDragEvents(false);
			EOnDragReleased.Broadcast();
			DestroyActor();
		}
		// Need to remove survivor from pool here
	}

	UFUNCTION()
	void EnableSurvivor(bool bEnabled = true)
	{
		if (bEnabled)
		{
			AttackResponseComponent.ResumeAttack();
			RageWorldWidget.SetVisibility(true);
			RageResponseComponent.ComponentTickEnabled = true;
		}
		else
		{
			AttackResponseComponent.PauseAttack();
			RageWorldWidget.SetVisibility(false);
			RageResponseComponent.ComponentTickEnabled = false;
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
		if (IsValid(OtherTargetComp)
			&& OtherTargetComp.TargetType == ETargetType::Bowling
			&& StruckType == GameplayTags::Description_StruckType_Absorb)
		{
			OtherActor.DestroyActor();
		}
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
			// float PlayRate = InteractSystem.GetValue(AttackAttrSet::AttackCooldown);
			// PlayRate = Weapon.AttackAnim.PlayLength > PlayRate ? Weapon.AttackAnim.PlayLength / PlayRate : 1;
			AnimateInst.Montage_Play(MainWeapon.AttackAnim);
		}
	}

	UFUNCTION()
	private void OnMontageEnded(UAnimMontage Montage, bool bInterrupted)
	{
		// if (Montage == Weapon.AttackAnim)
		// {
		// AttackResponseComponent.EOnAnimEndNotify.Broadcast();
		//}
	}

	UFUNCTION()
	private void OnActorTagAdded(FGameplayTagContainer TagContainer)
	{
		if (TagContainer.HasTagExact(GameplayTags::Description_Weapon_DualWield))
		{
			AnimateInst.DualWieldRate = 1;
		}
	}

	UFUNCTION()
	private void OnActorTagRemoved(FGameplayTag Tag)
	{
		if (Tag.MatchesTag(GameplayTags::Description_Weapon_DualWield))
		{
			AnimateInst.DualWieldRate = 0;
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
		return MainWeapon.GetSocketLocation(n"Muzzle");
	}

	UFUNCTION()
	FVector GetOffhandAttackLocation()
	{
		return OffWeapon.GetSocketLocation(n"Muzzle");
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
