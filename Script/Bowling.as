class ABowling : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Collider;
    default Collider.SimulatePhysics = true;

    UPROPERTY(DefaultComponent,Attach = Collider)
    UStaticMeshComponent BowlingMesh;
    default BowlingMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

    UPROPERTY( BlueprintReadOnly )
	UMaterialInstanceDynamic MaterialInstance;

    UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
        MaterialInstance = Material::CreateDynamicMaterialInstance(BowlingMesh.GetMaterial(0));
		BowlingMesh.SetMaterial(0, MaterialInstance);
    }

    void Fire(FVector Direction, float Force)
    {
        Collider.AddForce(Direction * Force);
    }
}
