class ADropObject : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;
	default Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent DropMesh;
}
