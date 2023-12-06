enum EStatus
{
	None,
	Fire,
	Ice
}

class ABowling : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;
	default Collider.SimulatePhysics = true;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent BowlingMesh;
	default BowlingMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent, Attach = Collider)
	UParticleSystemComponent StatusEffect;
	default StatusEffect.Activate(false);
	default StatusEffect.AutoActivate = false;

	UPROPERTY(BlueprintReadOnly)
	UMaterialInstanceDynamic MaterialInstance;

	UPROPERTY(BlueprintReadOnly)
	EStatus Status = EStatus::Fire;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0, MaterialInstance);
		if (Status == EStatus::Fire)
		{
			StatusEffect.Activate(true);
		}
	}

	void Fire(FVector Direction, float Force)
	{
		Collider.AddForce(Direction * Force);
	}
}
