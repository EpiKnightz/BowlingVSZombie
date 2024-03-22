class AHumanlite : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USkeletalMeshComponent BodyMesh;

	UPROPERTY(DefaultComponent, Attach = BodyMesh)
	USkeletalMeshComponent HeadMesh;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		HeadMesh.SetLeaderPoseComponent(BodyMesh);
	}
};