class AZombie : AActor
{
    UPROPERTY()
    float MoveSpeed = 100;

    UPROPERTY(DefaultComponent)
    USkeletalMeshComponent ZombieSkeleton;

    float delayMove = 3;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        delayMove -= DeltaSeconds;
        if (delayMove<=0)
        {
            FVector loc = GetActorLocation();
            loc.X += MoveSpeed * DeltaSeconds;
            SetActorLocation(loc);
        }
    }

    void SetSkeletonMesh(USkeletalMesh mesh)
    {
        ZombieSkeleton.SkeletalMeshAsset = mesh;
    }
}
