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

	UPROPERTY(DefaultComponent, Attach = HeadMesh, AttachSocket = "HEAD_CONTAINER") // , AttachSocket = RightHand
	UStaticMeshComponent AccessoryMesh;
	default AccessoryMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default AccessoryMesh.CollisionProfileName = n"NoCollision";
	default AccessoryMesh.ReceivesDecals = false;
	default HeadMesh.SetWorldScale3D(FVector::OneVector);

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	TArray<UAnimMontage> DeadAnims;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent StatusWorldWidget;
	UUIStatusBar StatusBarWidget;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UWidgetComponent HPWorldWidget;
	UUIHPBar HPBarWidget;

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
		AccessoryMesh.SetMaterial(0, ColorOverlay.DynamicMat);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		HPBarWidget = Cast<UUIHPBar>(HPWorldWidget.GetWidget());
		StatusBarWidget = Cast<UUIStatusBar>(StatusWorldWidget.GetWidget());
	}

	void SetMeshes(USkeletalMesh InBodyMesh, UStaticMesh InHeadMesh, UStaticMesh InAccMesh)
	{
		if (IsValid(InHeadMesh))
		{
			HeadMesh.StaticMesh = InHeadMesh;
		}
		if (IsValid(InBodyMesh))
		{
			BodyMesh.SkeletalMeshAsset = InBodyMesh;
		}
		if (IsValid(InAccMesh))
		{
			AccessoryMesh.StaticMesh = InAccMesh;
		}
	}

	void SetBodyScale(FVector Scale)
	{
		// BodyMesh.SetRelativeScale3D(Scale);
		SetActorScale3D(Scale);
		// Collider.CapsuleHalfHeight = COLLIDER_BASE_HEIGHT * Scale.Z;
		// Collider.CapsuleRadius = COLLIDER_BASE_RADIUS * (Scale.X > Scale.Y ? Scale.X : Scale.Y);
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

	void PlayDeadAnim(int AnimIndex) {}
};