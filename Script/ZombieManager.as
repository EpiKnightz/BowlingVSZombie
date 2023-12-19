class AZombieManager : AActor
{
	UPROPERTY()
	TSubclassOf<AZombie> ZombieTemplate;

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
			FZombieDT Row;
			ZombieDataTable.FindRow(FName("" + Math::RandRange(1, 3)), Row);

			FVector SpawnLocation = SpawnPosition.Location;
			SpawnLocation.Y = Math::RandRange(-SpawnSize, SpawnSize);
			SpawnLocation.Z *= Row.Scale.Z;

			AZombie SpawnedActor = Cast<AZombie>(SpawnActor(ZombieTemplate, SpawnLocation, SpawnPosition.Rotator()));
			SpawnedActor.SetData(Row.HP, Row.Atk, Row.Speed, Row.AtkSpeed, Row.Scale);

			int randomZombieIdx = Math::RandRange(0, Row.ZombieModelList.Num() - 1);
			SpawnedActor.SetSkeletonMesh(Row.ZombieModelList[randomZombieIdx]);

			ABowlingGameMode GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
			SpawnedActor.ZombDieEvent.BindUFunction(GM, n"ScoreUp");
			SpawnedActor.ZombieReachEvent.BindUFunction(GM, n"HPLost");

			countdown = Math::RandRange(SpawnTimeMin, SpawnTimeMax);
		}
	}
}
