class AHumanlite : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCapsuleComponent Collider;
	default Collider.CapsuleHalfHeight = 80;
	default Collider.CapsuleRadius = 50;
	default Collider.SimulatePhysics = false;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent BodyMesh;
	default BodyMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default BodyMesh.ReceivesDecals = false;

	UPROPERTY(DefaultComponent, Attach = BodyMesh)
	USkeletalMeshComponent HeadMesh;
	default HeadMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default HeadMesh.ReceivesDecals = false;

	UPROPERTY(DefaultComponent, Attach = HeadMesh) // , AttachSocket = RightHand
	USkeletalMeshComponent AccessoryMesh;
	default AccessoryMesh.CollisionEnabled = ECollisionEnabled::NoCollision;
	default AccessoryMesh.ReceivesDecals = false;

	protected UMaterialInstanceDynamic DynamicMat;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		HeadMesh.SetLeaderPoseComponent(BodyMesh);
		AccessoryMesh.SetLeaderPoseComponent(BodyMesh);
		DynamicMat = Material::CreateDynamicMaterialInstance(BodyMesh.GetMaterial(0));
		BodyMesh.SetMaterial(0, DynamicMat);
		HeadMesh.SetMaterial(0, DynamicMat);
		AccessoryMesh.SetMaterial(0, DynamicMat);
	}

	void SetBodyScale(FVector Scale)
	{
		BodyMesh.SetRelativeScale3D(Scale);
	}

	void SetHeadScale(FVector Scale)
	{
		float BodyZ = BodyMesh.GetRelativeScale3D().Z;
		HeadMesh.SetRelativeScale3D(Scale / BodyMesh.GetRelativeScale3D());
		HeadMesh.SetRelativeLocation(FVector(0, 0, 100 - 100 * Scale.Z / BodyZ));
	}

	UFUNCTION()
	void EndHitFlash()
	{
		ChangeAddedColor(FLinearColor::Transparent);
	}

	UFUNCTION()
	void ChangeAddedColor(FLinearColor Color)
	{
		if (Color.A == 0)
		{
			DynamicMat.SetScalarParameterValue(n"IsAddEnable", 0);
		}
		else
		{
			DynamicMat.SetScalarParameterValue(n"IsAddEnable", 1);
			DynamicMat.SetVectorParameterValue(n"AddedColor", Color);
		}
	}
};