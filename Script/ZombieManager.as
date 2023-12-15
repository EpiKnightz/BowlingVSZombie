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

	UPROPERTY(BlueprintReadWrite)
	float SpawnTimeMin = 1;

	UPROPERTY(BlueprintReadWrite)
	float SpawnTimeMax = 2;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieDataTable;

	float countdown = 1;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		countdown -= DeltaSeconds;
		if (countdown <= 0)
		{
			FVector SpawnLocation = SpawnPosition.Location;
			SpawnLocation.Y = Math::RandRange(-SpawnSize, SpawnSize);
			AZombie SpawnedActor = Cast<AZombie>(SpawnActor(ZombieTemplate, SpawnLocation, SpawnPosition.Rotator()));
			countdown = Math::RandRange(SpawnTimeMin, SpawnTimeMax);

			// ZombieDataTable.GetRow();
			FZombieDT Row;
			ZombieDataTable.FindRow(FName("NewRow"), Row);
			SpawnedActor.SetData(Row.HP, Row.Atk, Row.Speed);

			int randomZombieIdx = Math::RandRange(0, ZombieList.Num() - 1);

			SpawnedActor.SetSkeletonMesh(ZombieList[randomZombieIdx]);

			ABowlingGameMode GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
			SpawnedActor.ZombDieEvent.BindUFunction(GM, n"ScoreUp");
			SpawnedActor.ZombieReachEvent.BindUFunction(GM, n"HPLost");
		}
	}
}
