class AZombieManager : AActor
{
    UPROPERTY()
    TSubclassOf<AZombie> ZombieTemplate;

    UPROPERTY()
    TArray<USkeletalMesh> ZombieList;

    UPROPERTY()
    FTransform SpawnPosition;

    UPROPERTY()
    float SpawnSize;

    float countdown = 1;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        countdown -= DeltaSeconds;
        if (countdown <= 0)
        {
            FVector SpawnLocation = SpawnPosition.Location;
            SpawnLocation.Y = Math::RandRange(-SpawnSize,SpawnSize);
            AZombie SpawnedActor = Cast<AZombie>(SpawnActor(ZombieTemplate,SpawnLocation,SpawnPosition.Rotator()));
            countdown = Math::RandRange(1.0f,2.0f);

            int randomZombieIdx = Math::RandRange(0,ZombieList.Num()-1);

            SpawnedActor.SetSkeletonMesh(ZombieList[randomZombieIdx]);
        }
    }
}
