class AZombieManager : AActor
/**
 * ZombieManager class manages spawning zombies.
 *
 * It contains properties for configuring zombie spawning like spawn position, spawn rate, and zombie data table.
 *
 * The Tick() function handles spawning zombies periodically:
 * - It uses the zombie data table to get random zombie data each spawn
 * - It spawns the zombie actor at a random position using the configured spawn position and range
 * - It sets up the spawned zombie's properties using the zombie data table
 * - It equips the zombie with random weapons based on the socket types
 * - It binds events for the zombie's death and reaching the player
 * - It resets the spawn counter for the next spawn
 */
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
	void BeginPlay()
	{
		ActorTickEnabled = false;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		countdown -= DeltaSeconds;
		if (countdown <= 0)
		{
			FZombieDT Row;
			ZombieDataTable.FindRow(FName("" + Math::RandRange(1, 5)), Row);

			FVector SpawnLocation = SpawnPosition.Location;
			SpawnLocation.Y = Math::RandRange(-SpawnSize, SpawnSize);
			SpawnLocation.Z *= Row.Scale.Z;

			AZombie SpawnedActor = Cast<AZombie>(SpawnActor(ZombieTemplate, SpawnLocation, SpawnPosition.Rotator()));
			SpawnedActor.SetData(Row.HP, Row.Atk, Row.Dmg, Row.Speed, Row.AtkSpeed, Row.Scale);

			int randomZombieIdx = Math::RandRange(0, Row.ZombieModelList.Num() - 1);
			SpawnedActor.SetSkeletonMesh(Row.ZombieModelList[randomZombieIdx]);

			// Set weapon
			UStaticMesh RightHand = nullptr, LeftHand = nullptr;
			if (Row.RightSocketType == Row.LeftSocketType && Row.RightSocketType == ESocketType::Hand)
			{
				if (Math::RandBool())
				{
					RightHand = Row.RightWeaponList[Math::RandRange(0, Row.RightWeaponList.Num() - 1)];
				}
				else
				{
					LeftHand = Row.LeftWeaponList[Math::RandRange(0, Row.LeftWeaponList.Num() - 1)];
				}
			}
			else
			{
				if (Row.RightSocketType != ESocketType::None)
				{
					RightHand = Row.RightWeaponList[Math::RandRange(0, Row.RightWeaponList.Num() - 1)];
				}
				if (Row.LeftSocketType != ESocketType::None)
				{
					LeftHand = Row.LeftWeaponList[Math::RandRange(0, Row.LeftWeaponList.Num() - 1)];
				}
			}
			SpawnedActor.SetWeapon(RightHand, LeftHand, Row.RightSocketType == ESocketType::DualWield, EAttackType::Punch);

			ABowlingGameMode GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
			SpawnedActor.ZombDieEvent.BindUFunction(GM, n"ScoreChange");
			SpawnedActor.ZombieReachEvent.BindUFunction(GM, n"HPChange");

			countdown = Math::RandRange(SpawnTimeMin, SpawnTimeMax);
		}
	}
}
