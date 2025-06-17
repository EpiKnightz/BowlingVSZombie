enum EBossPhase
{
	// Roar = 0,		  // Transition phase
	SummonPhase = 1,  // Phase 1	: Summon zombies, don't attack
	AttackPhase = 2,  // Phase 2	: Under 60% HP, start attacking
	BerserkPhase = 3, // Phase 3: Under 30% HP, Berserk, both attack and summon
	DeadPhase = 4,	  // Finish
}

const float BOSS_SIZE = 3;

class AZombieBoss : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;
	default Collider.BodyInstance.bNotifyRigidBodyCollision = true;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent BossMesh;

	UPROPERTY(DefaultComponent, Attach = BossMesh, AttachSocket = RightWeapon)
	UStaticMeshComponent WeaponMesh;

	UPROPERTY(DefaultComponent)
	UDamageResponseComponent DamageResponseComponent;

	UPROPERTY(DefaultComponent)
	UMovementResponseComponent MovementResponseComponent;

	UPROPERTY(DefaultComponent)
	UAttackResponseComponent AttackResponseComponent;

	UPROPERTY(DefaultComponent)
	UStatusResponseComponent StatusResponseComponent;

	UPROPERTY(DefaultComponent)
	UTargetResponseComponent TargetResponseComponent;
	default TargetResponseComponent.TargetType = ETargetType::Zombie;

	UPROPERTY(DefaultComponent)
	UCinematicResponseComponent CinematicResponseComponent;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem SmackVFX;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage DanceAnims;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> WeaponAttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage RoarAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> DamageAnim;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage DeadAnims;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent HitSFX;

	UPROPERTY(BlueprintReadWrite, Category = SFX)
	UFMODEvent DeadSFX;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem DeadVFX;

	UPROPERTY(BlueprintReadWrite, Category = VFX)
	UNiagaraSystem GroundImpactVFX;

	protected float CoinValue;
	protected TArray<UModifierObject> Lv1Modifiers;
	protected TArray<UModifierObject> Lv2Modifiers;
	protected TArray<UModifierObject> Lv3Modifiers;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieStatusTable;

	UPROPERTY(Category = Drop)
	TSubclassOf<ACoin> CoinTemplate;

	UZombieBossAnimInst AnimateInst;
	FNameDelegate DOnZombDie;
	FFloatNameDelegate DOnZombieReach;

	float EmergeTime = 1.3;
	EBossPhase CurrentPhase = EBossPhase::SummonPhase;

	UPROPERTY(DefaultComponent)
	UInteractSystem InteractSystem;

	private UDamageResponseComponent Target;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent MovementComp;
	default MovementComp.bShouldBounce = true;
	default MovementComp.ProjectileGravityScale = 0;
	default MovementComp.bConstrainToPlane = true;
	default MovementComp.PlaneConstraintAxisSetting = EPlaneConstraintAxisSetting::UseGlobalPhysicsSetting;
	default MovementComp.PlaneConstraintNormal = FVector(0, 0, 1);
	default MovementComp.AutoActivate = false;
	default MovementComp.Bounciness = 0.8;

	UPROPERTY()
	TSubclassOf<UCameraShakeBase> ShakeStyle;

	UPROPERTY(Category = StaticMesh)
	UStaticMesh WeaponMeshTemplate;

	protected UFCTweenBPActionFloat FloatTween;
	protected UColorOverlay ColorOverlay;
	AZombieManager ZombieManager;
	AZombie SpawnedZombie;

	UPROPERTY()
	UModifierObject ImmuneMod;

	private ATemplateSequenceActor TemplSequActor;
	UPROPERTY()
	UTemplateSequence IntroSequence;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AnimateInst = Cast<UZombieBossAnimInst>(BossMesh.GetAnimInstance());

		ColorOverlay = NewObject(this, UColorOverlay);
		ColorOverlay.SetupDynamicMaterial(BossMesh.GetMaterial(0));
		BossMesh.SetMaterial(0, ColorOverlay.DynamicMat);

		// Collider.OnComponentHit.AddUFunction(this, n"OnHit");

		InteractSystem.RegisterAttrSet(UPrimaryAttrSet);
		InteractSystem.RegisterAttrSet(UAttackAttrSet);
		InteractSystem.RegisterAttrSet(UMovementAttrSet);
		InteractSystem.EOnPostCalculation.AddUFunction(this, n"OnPostCalculation");

		DamageResponseComponent.Initialize(InteractSystem);
		DamageResponseComponent.EOnHitCue.AddUFunction(this, n"TakeHitCue");
		DamageResponseComponent.EOnDamageCue.AddUFunction(this, n"TakeDamageCue");
		DamageResponseComponent.EOnDeadCue.AddUFunction(this, n"DeadCue");

		StatusResponseComponent.Initialize(InteractSystem);
		StatusResponseComponent.DChangeOverlayColor.BindUFunction(ColorOverlay, n"ChangeOverlayColor");

		AttackResponseComponent.Initialize(InteractSystem);
		AttackResponseComponent.EOnAnimHitNotify.AddUFunction(this, n"OnSummonAttackHitNotify");

		MovementResponseComponent.Initialize(InteractSystem);
		MovementResponseComponent.EOnBounceCue.AddUFunction(this, n"OnBounceCue");
		MovementResponseComponent.EOnPreAddForceCue.AddUFunction(this, n"OnPreAddForceCue");
		MovementResponseComponent.SetIsBouncable(false);
		MovementResponseComponent.SetIsAccelable(true);

		CinematicResponseComponent.Initialize(InteractSystem);
		CinematicResponseComponent.EOnImpact.AddUFunction(this, n"OnImpactGround");

		ZombieManager = Gameplay::GetActorOfClass(AZombieManager);

		AnimateInst.AnimPlayRate = 0;
		ZoomUpCamera();

		TemplSequActor = NewObject(this, ATemplateSequenceActor);
		UTemplateSequencePlayer::CreateTemplateSequencePlayer(IntroSequence, FMovieSceneSequencePlaybackSettings(), TemplSequActor);
		TemplSequActor.SetBinding(this);
		TemplSequActor.GetSequencePlayer().SetPlayRate(1 / Gameplay::GetGlobalTimeDilation());
		TemplSequActor.GetSequencePlayer().Play();
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (OtherActor.IsA(ASurvivor) || OtherActor.IsA(AObstacle))
		{
			Target = UDamageResponseComponent::Get(OtherActor);
			PlayAttackAnim();
		}
	}

	UFUNCTION()
	private void OnPostCalculation(FName AttrName, float Value)
	{
		if (AttrName == PrimaryAttrSet::Damage && Value > 0)
		{
			float HPPercentage = InteractSystem.GetValue(PrimaryAttrSet::HP) / InteractSystem.GetValue(PrimaryAttrSet::MaxHP);
			ZombieManager.DOnProgressChanged.ExecuteIfBound(HPPercentage);
			if (HPPercentage <= 0.3 && CurrentPhase == EBossPhase::AttackPhase)
			{
				// Berserk Phase
				PlayRoarAnim();
			}
			else if (HPPercentage <= 0.6 && CurrentPhase == EBossPhase::SummonPhase)
			{
				// Attack Phase
				PlayRoarAnim();
			}
		}
	}

	UFUNCTION()
	void SetData(FZombieDT DataRow)
	{
		TMap<FName, float32> Data;
		Data.Add(PrimaryAttrSet::MaxHP, DataRow.HP);
		Data.Add(AttackAttrSet::Attack, DataRow.Atk);
		Data.Add(AttackAttrSet::AttackCooldown, DataRow.AttackCooldown);
		Data.Add(MovementAttrSet::MoveSpeed, DataRow.Speed);
		Data.Add(MovementAttrSet::Accel, DataRow.Accel);
		Data.Add(MovementAttrSet::Bounciness, DataRow.Bounciness);

		InteractSystem.ImportData(Data);

		ZombieManager.DOnProgressChanged.ExecuteIfBound(1);

		SetActorScale3D(DataRow.BodyScale);
		CoinValue = DataRow.CoinDropAmount;
		Lv1Modifiers = DataRow.Lv1Modifiers;
		Lv2Modifiers = DataRow.Lv2Modifiers;
		Lv3Modifiers = DataRow.Lv3Modifiers;
	}

	UFUNCTION()
	void SummonZombie()
	{
		SpawnedZombie = ZombieManager.ConstructZombie(WeaponMesh.WorldLocation);
		SpawnedZombie.EmergeDone();
		SpawnedZombie.SetActorTickEnabled(false);
		SpawnedZombie.AttachToComponent(WeaponMesh, n"", EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);
		SpawnedZombie.SetActorRelativeLocation(FVector(0.4, -3.5, 3.3));
		SpawnedZombie.SetActorRelativeRotation(FRotator(22, 0, 110));
	}

	UFUNCTION()
	void SummonZombie2()
	{
		SummonZombie();
	}

	UFUNCTION()
	void SummonZombie3()
	{
		SummonZombie();
	}

	UFUNCTION(BlueprintCallable)
	void EmergeDone()
	{
		if (AnimateInst.bIsEmergeDone == false)
		{
			AnimateInst.bIsEmergeDone = true;
		}
	}

	UFUNCTION()
	void StartMoving()
	{
		switch (CurrentPhase)
		{
			case EBossPhase::SummonPhase:
			{
				System::SetTimer(this, n"PlaySummonAnim", InteractSystem.GetValue(AttackAttrSet::AttackCooldown), false);
				break;
			}
			case EBossPhase::AttackPhase:
			{
				System::SetTimer(this, n"PlayTripleSummonAnim", InteractSystem.GetValue(AttackAttrSet::AttackCooldown), false);
				// Spawn faster
				break;
			}
			case EBossPhase::BerserkPhase:
			{
				// Move forward to attack
				if (WeaponMesh.StaticMesh == nullptr)
				{
					WeaponMesh.StaticMesh = WeaponMeshTemplate;
				}
				AnimateInst.MoveDirection = EMoveDirection::Forward;
				break;
			}
			case EBossPhase::DeadPhase:
			{
				return;
			}
			default:
				break;
		}

		if (AnimateInst.MoveDirection == EMoveDirection::None)
		{
			AnimateInst.RandomizeMoveDirection();
		}
		FVector MoveVector;
		switch (AnimateInst.MoveDirection)
		{
			case EMoveDirection::Left:
			{
				MoveVector = FVector(0, -1, 0);
				break;
			}
			case EMoveDirection::Right:
			{
				MoveVector = FVector(0, 1, 0);
				break;
			}
			case EMoveDirection::Forward:
			{
				MoveVector = FVector(1, 0, 0);
				break;
			}
			case EMoveDirection::Backward:
			{
				MoveVector = FVector(-1, 0, 0);
				break;
			}
			default:
				break;
		}
		MovementResponseComponent.InitForce(MoveVector, 1);
		AnimateInst.SetMoveSpeed(InteractSystem.GetValue(MovementAttrSet::MoveSpeed));
	}

	void StopMoving()
	{
		MovementResponseComponent.EnableMovement(false);
	}

	////////////////////////////////////
	// Visual Cues
	////////////////////////////////////

	UFUNCTION()
	void ZoomUpCamera()
	{
		auto FocusTracker = Gameplay::GetActorOfClass(AFocusTracker);
		FocusTracker.SetActorRelativeLocation(FVector(0, 0, -170));
		FocusTracker.AttachToActor(this);
		FocusTracker.EOnSequenceFinished.AddUFunction(this, n"OnSequenceFinished");
		FocusTracker.EOnZoomInFinished.AddUFunction(this, n"OnZoomInFinished");
		FocusTracker.EOnTextIntroStarted.AddUFunction(this, n"OnTextIntroStarted");
		FocusTracker.EOnTextIntroFinished.AddUFunction(this, n"OnTextIntroFinished");

		auto GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
		GM.PlayZoomBossIntro(true);
	}

	UFUNCTION()
	private void OnTextIntroStarted()
	{
		// Gameplay::SetGlobalTimeDilation(0.5);
		AnimateInst.StopSlotAnimation();
		AnimateInst.Montage_Play(DanceAnims);
	}

	UFUNCTION()
	private void OnTextIntroFinished()
	{
		// Gameplay::SetGlobalTimeDilation(1);
	}

	UFUNCTION()
	private void OnZoomInFinished()
	{
		AnimateInst.AnimPlayRate = 1;
		System::SetTimer(this, n"EmergeDone", EmergeTime, false);
	}

	UFUNCTION()
	private void SetZLocation(float32 ZChange)
	{
		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, ZChange));
	}

	UFUNCTION()
	private void OnSequenceFinished()
	{
		StartMoving();
		auto GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
		GM.PlayZoomBossIntro(false);
	}

	UFUNCTION()
	private void PlaySummonAnim()
	{
		StopMoving();
		// Need to pause movement while throwing
		AnimateInst.StopSlotAnimation();
		AnimateInst.Montage_Play(WeaponAttackAnim[0]);
		AnimateInst.OnMontageEnded.Clear();
		AnimateInst.OnMontageEnded.AddUFunction(this, n"OnSummonAnimEnded");
		System::SetTimer(this, n"SummonZombie", 0.4, false);
	}

	UFUNCTION()
	private void PlayTripleSummonAnim()
	{
		StopMoving();
		// Need to pause movement while throwing
		AnimateInst.StopSlotAnimation();
		AnimateInst.Montage_Play(WeaponAttackAnim[1]);
		AnimateInst.OnMontageEnded.Clear();
		AnimateInst.OnMontageEnded.AddUFunction(this, n"OnSummonAnimEnded");
		System::SetTimer(this, n"SummonZombie", 0.4, false);
		System::SetTimer(this, n"SummonZombie2", 1.4, false);
		System::SetTimer(this, n"SummonZombie3", 2.4, false);
	}

	UFUNCTION()
	private void OnSummonAnimEnded(UAnimMontage Montage, bool bInterrupted)
	{
		StartMoving();
	}

	UFUNCTION()
	void PlayRoarAnim()
	{
		// Play Roar animation
		StopMoving();
		AnimateInst.StopSlotAnimation();
		AnimateInst.OnMontageEnded.Clear();
		AnimateInst.Montage_Play(RoarAnim);
		if (SpawnedZombie != nullptr)
		{
			OnSummonAttackHitNotify();
		}
		System::SetTimer(this, n"OnRoarAnimEnded", RoarAnim.GetPlayLength(), false);
		System::ClearTimer(this, "SummonZombie");
		System::ClearTimer(this, "PlaySummonAnim");
		System::ClearTimer(this, "PlayTripleSummonAnim");
		// Immune to damage while roaring
		// UOverrideMod Mod = NewObject(this, UOverrideMod);
		// Mod.SetupOnce(0, 0);
		// InteractSystem.AddModifier(PrimaryAttrSet::Damage, Mod, false);
		ImmuneMod.AddToAbilitySystem(InteractSystem);
		// Switch mode
		SwitchPhase();
		ZombieManager.NextWave();
	}

	void SwitchPhase(bool bUp = true)
	{
		switch (CurrentPhase)
		{
			case EBossPhase::SummonPhase:
			{
				CurrentPhase = EBossPhase::AttackPhase;
				break;
			}
			case EBossPhase::AttackPhase:
			{
				CurrentPhase = EBossPhase::BerserkPhase;
				break;
			}
			case EBossPhase::BerserkPhase:
			case EBossPhase::DeadPhase:
			default:
				break;
		}
	}

	UFUNCTION()
	void OnRoarAnimEnded()
	{
		// InteractSystem.RemoveModifier(PrimaryAttrSet::Damage, this, 0);
		ImmuneMod.RemoveFromAbilitySystem(InteractSystem);
		switch (CurrentPhase)
		{
			case EBossPhase::AttackPhase:
			{
				AttackResponseComponent.EOnAnimHitNotify.Clear();
				AttackResponseComponent.EOnAnimHitNotify.AddUFunction(this, n"OnTripleAttackHitNotify");
				for (int i = 0; i < Lv2Modifiers.Num(); i++) // Need check null
				{
					Lv2Modifiers[i].AddToAbilitySystem(InteractSystem);
				}
				break;
			}
			case EBossPhase::BerserkPhase:
			{
				AttackResponseComponent.EOnAnimHitNotify.Clear();
				AttackResponseComponent.EOnAnimHitNotify.AddUFunction(this, n"OnBerserkAttackHitNotify");
				for (int i = 0; i < Lv3Modifiers.Num(); i++)
				{
					Lv3Modifiers[i].AddToAbilitySystem(InteractSystem);
				}
				MovementResponseComponent.EOnBounceCue.Unbind(this, n"OnBounceCue");
				break;
			}
			default:
				PrintWarning("Phase not supported");
				break;
		}
		StartMoving();
	}

	UFUNCTION()
	void PlayAttackAnim()
	{
		StopMoving();
		AnimateInst.StopSlotAnimation();
		AnimateInst.Montage_Play(WeaponAttackAnim[2]);
		// Cast shockwave
		AnimateInst.OnMontageEnded.Clear();
		AnimateInst.OnMontageEnded.AddUFunction(this, n"OnAttackAnimEnded");
	}

	UFUNCTION()
	void PlayBerserkAnim()
	{
		StopMoving();
		AnimateInst.StopSlotAnimation();
		AnimateInst.Montage_Play(WeaponAttackAnim[3]);
		// Cast shockwave
		AnimateInst.OnMontageEnded.Clear();
		AnimateInst.OnMontageEnded.AddUFunction(this, n"OnAttackAnimEnded");
	}

	UFUNCTION()
	private void OnAttackAnimEnded(UAnimMontage Montage, bool bInterrupted)
	{
		if (Target.bIsDead)
		{
			System::SetTimer(this, n"StartMoving", 1, false);
		}
		else
		{
			// System::SetTimer(this, n"PlayAttackAnim", InteractSystem.GetValue(AttackAttrSet::AttackCooldown), false);
			PlayAttackAnim();
		}
	}

	UFUNCTION()
	private void OnPreAddForceCue(FVector Value)
	{
	}

	UFUNCTION()
	private void OnBounceCue(FHitResult HitResult)
	{
		AnimateInst.OppositeMoveDirection();
	}

	UFUNCTION()
	private void OnSummonAttackHitNotify()
	{
		SpawnedZombie.DetachFromActor(EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld);
		SpawnedZombie.ThrowToGroundTween(350);
		SpawnedZombie = nullptr;
	}

	UFUNCTION()
	private void OnTripleAttackHitNotify()
	{
		SpawnedZombie.DetachFromActor(EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld);
		SpawnedZombie.ThrowToGroundTween(650, true);
		SpawnedZombie = nullptr;
	}

	UFUNCTION()
	private void OnBerserkAttackHitNotify()
	{
		if (IsValid(Target))
		{
			Target.DOnTakeDamage.ExecuteIfBound(InteractSystem.GetValue(AttackAttrSet::Attack));
		}
	}

	UFUNCTION()
	private void TakeHitCue()
	{
	}

	UFUNCTION()
	void TakeDamageCue()
	{
		ColorOverlay.ChangeOverlayColor(FLinearColor::Red);
		System::SetTimer(ColorOverlay, n"RevertOverlayColor", 0.25, false);
		// AnimateInst.Montage_Play(DamageAnim);
		//  FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
	}

	UFUNCTION()
	void DeadCue()
	{
		StopMoving();
		CurrentPhase = EBossPhase::DeadPhase;
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);

		System::ClearTimer(ColorOverlay, "RevertOverlayColor");
		ColorOverlay.ChangeOverlayColor(FLinearColor::Gray, true);
		PlayDeadAnim();

		StatusResponseComponent.DChangeOverlayColor.Clear();

		MovementComp.StopSimulating(FHitResult());
		DOnZombDie.ExecuteIfBound(GetName());

		Niagara::SpawnSystemAtLocation(DeadVFX, GetActorLocation() + FVector(0, 0, 220)); // TODO: Change this with HeadMesh Location, also need to consider the scale
		FMODBlueprint::PlayEventAtLocation(this, DeadSFX, GetActorTransform(), true);

		ACoin SpawnedActor = Cast<ACoin>(SpawnActor(CoinTemplate, GetActorLocation(), GetActorRotation()));
		SpawnedActor.ExpectValueToCoinType(CoinValue);

		System::SetTimer(ZombieManager, n"GameEnd", 3, false);
	}

	void PlayDeadAnim()
	{
		AnimateInst.StopSlotAnimation();
		AnimateInst.Montage_Play(DeadAnims, 1);
		// delayMove = DeadAnims.GetPlayLength();
	}

	UFUNCTION()
	private void OnImpactGround()
	{
		FVector ImpactLocation = GetActorLocation();
		ImpactLocation.Z = 0;
		Niagara::SpawnSystemAtLocation(GroundImpactVFX, ImpactLocation);
	}
};