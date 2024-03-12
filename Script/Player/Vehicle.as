class AVehicle : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USkeletalMeshComponent SkelMesh;

	UPROPERTY(DefaultComponent)
	UBoxComponent Collider;
};