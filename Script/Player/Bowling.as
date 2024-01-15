delegate void FBowlingHitDelegate(AActor OtherActor);

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

	FBowlingHitDelegate OnHit;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0, MaterialInstance);
		if (Status == EStatus::Fire)
		{
			StatusEffect.Activate(true);
		}
		Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
	}

	void Fire(FVector Direction, float Force)
	{
		Collider.AddForce(Direction * Force);
	}

	UFUNCTION()
	void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		OnHit.ExecuteIfBound(OtherActor);
	}
}
