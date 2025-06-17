const float HEAD_BASE_SCALE = 1 / 2.54;
const float COLLIDER_BASE_HEIGHT = 100;
const float COLLIDER_BASE_RADIUS = 50;

class AHumanlite : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCapsuleComponent Collider;
	default Collider.CapsuleHalfHeight = COLLIDER_BASE_HEIGHT;
	default Collider.CapsuleRadius = COLLIDER_BASE_RADIUS;
	default Collider.SimulatePhysics = false;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent BodyMesh;
	default BodyMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default BodyMesh.CollisionProfileName = n"NoCollision";
	default BodyMesh.ReceivesDecals = false;

	UPROPERTY(DefaultComponent, Attach = BodyMesh, AttachSocket = "Bip001-Neck")
	UStaticMeshComponent HeadMesh;
	default HeadMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default HeadMesh.CollisionProfileName = n"NoCollision";
	default HeadMesh.ReceivesDecals = false;
	// default HeadMesh.Setrelat(FVector::OneVector * 0.4);
	default HeadMesh.SetRelativeRotation(FRotator(90, -180, 0));

	UPROPERTY(DefaultComponent, Attach = HeadMesh, AttachSocket = "HEAD_CONTAINER")
	UStaticMeshComponent AccessoryMesh;
	default AccessoryMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default AccessoryMesh.CollisionProfileName = n"NoCollision";
	default AccessoryMesh.ReceivesDecals = false;
	default HeadMesh.SetWorldScale3D(FVector::OneVector);

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

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> DeadAnims;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent StatusWorldWidget;
	default StatusWorldWidget.SetTickMode(ETickMode::Automatic);
	UUIStatusBar StatusBarWidget;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent HPWorldWidget;
	default HPWorldWidget.SetTickMode(ETickMode::Automatic);
	UUIHPBar HPBarWidget;

	UPROPERTY(DefaultComponent)
	UInteractSystem InteractSystem;

	UPROPERTY()
	TSubclassOf<UAnimInstance> Testing;

	protected UFCTweenBPActionFloat FloatTween;
	protected UColorOverlay ColorOverlay;
	protected FLinearColor DamageColor = FLinearColor::Red;

	///////////////////////////////////
	// Setup
	///////////////////////////////////

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		ColorOverlay = NewObject(this, UColorOverlay);
		ColorOverlay.SetupDynamicMaterial(BodyMesh.GetMaterial(0));
		BodyMesh.SetMaterial(0, ColorOverlay.DynamicMat);
		HeadMesh.SetMaterial(0, ColorOverlay.DynamicMat);
		// AccessoryMesh.SetMaterial(0, ColorOverlay.DynamicMat);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		HPBarWidget = Cast<UUIHPBar>(HPWorldWidget.GetWidget());
		StatusBarWidget = Cast<UUIStatusBar>(StatusWorldWidget.GetWidget());

		InteractSystem.RegisterAttrSet(UPrimaryAttrSet);
		InteractSystem.RegisterAttrSet(UAttackAttrSet);
		InteractSystem.RegisterAttrSet(UMovementAttrSet);
		InteractSystem.RegisterAttrSet(UWeaknessAttrSet);
	}

	void SetMeshes(USkeletalMesh InBodyMesh, UStaticMesh InHeadMesh, UStaticMesh InAccMesh)
	{
		if (IsValid(InHeadMesh))
		{
			HeadMesh.SetStaticMesh(InHeadMesh);
			for (int32 i = 0; i < InHeadMesh.StaticMaterials.Num(); i++)
			{
				HeadMesh.SetMaterial(i, InHeadMesh.StaticMaterials[i].MaterialInterface);
			}
		}
		if (IsValid(InBodyMesh))
		{
			BodyMesh.ForceSetSkeletalMeshAsset(InBodyMesh);
			for (int32 i = 0; i < InBodyMesh.Materials.Num(); i++)
			{
				BodyMesh.SetMaterial(i, InBodyMesh.Materials[i].MaterialInterface);
			}
		}
		if (IsValid(InAccMesh))
		{
			AccessoryMesh.SetStaticMesh(InAccMesh);
			for (int32 i = 0; i < InAccMesh.StaticMaterials.Num(); i++)
			{
				AccessoryMesh.SetMaterial(i, InAccMesh.StaticMaterials[i].MaterialInterface);
			}
		}
	}

	void SetBodyScale(FVector Scale)
	{
		// BodyMesh.SetRelativeScale3D(Scale);
		SetActorScale3D(Scale);
		Collider.CapsuleHalfHeight = COLLIDER_BASE_HEIGHT * Scale.Z;
		Collider.CapsuleRadius = COLLIDER_BASE_RADIUS * (Scale.X > Scale.Y ? Scale.X : Scale.Y);
	}

	void SetTempScale(FVector Scale)
	{
		BodyMesh.SetRelativeScale3D(GetActorScale3D());
		SetActorScale3D(Scale);
	}

	UFUNCTION()
	void ResetTempScale()
	{
		SetActorScale3D(BodyMesh.GetRelativeScale3D());
		BodyMesh.SetRelativeScale3D(FVector::OneVector);
	}

	void SetHeadScale(FVector Scale)
	{
		HeadMesh.SetRelativeScale3D(Scale * HEAD_BASE_SCALE / GetActorScale3D());
	}

	////////////////////////////////////
	// Visual Cues
	////////////////////////////////////

	void ChangeDamagedColor(FLinearColor Color)
	{
		DamageColor = Color;
	}

	UFUNCTION()
	void TakeDamageCue()
	{
		ColorOverlay.ChangeOverlayColor(DamageColor);
		System::SetTimer(ColorOverlay, n"RevertOverlayColor", 0.25, false);
		// AnimateInst.Montage_Play(DamageAnim);
		//  FMODBlueprint::PlayEventAtLocation(this, HitSFX, GetActorTransform(), true);
	}

	UFUNCTION()
	void DeadCue()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);

		System::ClearTimer(ColorOverlay, "RevertOverlayColor");
		ColorOverlay.ChangeOverlayColor(FLinearColor(0.2, 0.2, 0.2), true);

		int AnimIndex = Math::RandRange(0, DeadAnims.Num() - 1);
		PlayDeadAnim(AnimIndex);
	}

	void PlayDeadAnim(int AnimIndex)
	{}
};