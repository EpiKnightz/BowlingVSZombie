namespace ZombieManager
{
	const float WARNING_DURATION = 2.5;
}
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
	TSubclassOf<AZombieBoss> BossTemplate;

	UPROPERTY()
	FTransform SpawnPosition;

	UPROPERTY()
	float SpawnSize;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieDataTable;

	TArray<FSpawnSequenceDT> ZombieSequence;
	TArray<FName> ZombiePoolID;
	TSet<FName> SpawnedZombieList;

	UPROPERTY(BlueprintReadWrite)
	UDataTable SpawnSequenceDT;

	UPROPERTY(BlueprintReadWrite)
	float CurrentLevelProgress = 0;

	private float countdown = 1;
	private int currentSequenceMilestone = -1;
	private int nextSequenceMilestone = 0;
	private float endTimer = 9999;
	private float currentGameTime;
	private int multipleSpawnCount = 0;

	ABowlingGameMode GameMode;

	FFloatDelegate DOnProgressChanged;
	FFTextDelegate DShowWarning;
	FFTextDelegate DShowBossMsg;
	FVoidDelegate DOnClearedAllZombies;
	FZombieEvent EOnZombieSpawned;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorTickEnabled = false;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		countdown -= DeltaSeconds;
		currentGameTime += DeltaSeconds;
		if (currentGameTime >= endTimer)
		{
			if (ZombieSequence.Last().SpawnID.Num() == 1 && ZombieSequence.Last().SpawnID[0] == "End")
			{
				GameEnd();
				return;
			}
		}
		// Modify Zombie pool based on the current milestone
		if (nextSequenceMilestone < ZombieSequence.Num())
		{
			if (currentGameTime >= ZombieSequence[nextSequenceMilestone].TimeMark)
			{
				// Print(ZombieSequence[0].ZombieID[0].ToString());
				ZombiePoolID = ZombieSequence[nextSequenceMilestone].SpawnID;
				if (ZombiePoolID.Num() > 0)
				{
					currentSequenceMilestone = nextSequenceMilestone;
					if (currentSequenceMilestone == 0 && GameMode.LevelType == ELevelType::Boss)
					{
						SpawnBoss();
					}
					countdown = 0;
					nextSequenceMilestone++;
				}
				else
				{
					Print("ZombiePoolID is empty");
				}
			}
		}
		// Spawn zombie when countdown is <= 0
		if (countdown <= 0)
		{
			if (ZombiePoolID.Num() > 0 && !ZombieSequence[currentSequenceMilestone].bDataOnly)
			{
				if (ZombieSequence[currentSequenceMilestone].bAllowMultipleSpawns)
				{
					multipleSpawnCount = Math::RandRange(ZombieSequence[currentSequenceMilestone].MinSpawnPerMulti, ZombieSequence[currentSequenceMilestone].MaxSpawnPerMulti) - 1;
				}
				SpawnZombie();
				countdown = Math::RandRange(ZombieSequence[currentSequenceMilestone].MinWaveCooldown, ZombieSequence[currentSequenceMilestone].MaxWaveCooldown);
			}
		}
		// Update level progress
		UpdateProgress();
	}

	UFUNCTION()
	void SpawnBoss()
	{
		// TODO: Double check all other Zombie references
		if (GameMode.LevelType == ELevelType::Boss)
		{
			FZombieDT Row;
			FName ZombieID = ZombiePoolID[0];
			ZombieDataTable.FindRow(ZombieID, Row);

			FVector ScaledLocation = FindSpawnLocation();
			ScaledLocation.Z *= Row.BodyScale.Z;
			AZombieBoss Boss = SpawnActor(BossTemplate, ScaledLocation, SpawnPosition.Rotator());
			Boss.SetData(Row);

			Boss.DOnZombDie.BindUFunction(GameMode, n"ScoreChange");
			Boss.DOnZombDie.BindUFunction(this, n"UpdateZombieList");
			Boss.DOnZombieReach.BindUFunction(GameMode, n"HPChange");
			// EOnZombieSpawned.Broadcast(Boss);

			ZombiePoolID = ZombieSequence[nextSequenceMilestone + 1].SpawnID;
		}
	}

	UFUNCTION()
	void SpawnZombie()
	{
		/**
		 * Spawns a random zombie from the ZombiePoolID array based on
		 * the provided zombie data table row. Sets the zombie's stats
		 * based on the data table values. Randomly selects a zombie
		 * model from the available options in the data table row.
		 */

		ConstructZombie(FindSpawnLocation());

		if (multipleSpawnCount > 0)
		{
			multipleSpawnCount--;
			System::SetTimer(this, n"SpawnZombie", ZombieSequence[currentSequenceMilestone].MultipleSpawnInterval, false);
		}
	}

	UFUNCTION()
	void NextWave()
	{
		if (nextSequenceMilestone < ZombieSequence.Num())
		{
			ZombieSequence[nextSequenceMilestone].TimeMark = currentGameTime;
		}
	}

	AZombie ConstructZombie(FVector Location)
	{
		FZombieDT Row;
		FName ZombieID = ZombiePoolID[Math::RandRange(0, ZombiePoolID.Num() - 1)];
		ZombieDataTable.FindRow(ZombieID, Row);

		FVector ScaledLocation = Location;
		ScaledLocation.Z *= Row.BodyScale.Z;

		AZombie SpawnedActor = SpawnActor(ZombieTemplate, ScaledLocation, SpawnPosition.Rotator());

		USkeletalMesh BodyMesh = Row.BodyMeshList.Num() > 0 ? Row.BodyMeshList[Math::RandRange(0, Row.BodyMeshList.Num() - 1)] : nullptr;
		UStaticMesh HeadMesh = Row.HeadMeshList.Num() > 0 ? Row.HeadMeshList[Math::RandRange(0, Row.HeadMeshList.Num() - 1)] : nullptr;
		UStaticMesh AccessoryMesh = Row.AccessoryMeshList.Num() > 0 ? Row.AccessoryMeshList[Math::RandRange(0, Row.AccessoryMeshList.Num() - 1)] : nullptr;

		SpawnedActor.SetMeshes(BodyMesh, HeadMesh, AccessoryMesh);
		SpawnedActor.SetData(Row);

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
		SpawnedZombieList.Add(SpawnedActor.GetName());

		SpawnedActor.DOnZombDie.BindUFunction(GameMode, n"ScoreChange");
		SpawnedActor.DOnZombDie.BindUFunction(this, n"UpdateZombieList");
		SpawnedActor.DOnZombieReach.BindUFunction(GameMode, n"HPChange");
		EOnZombieSpawned.Broadcast(SpawnedActor);

		return SpawnedActor;
	}

	FVector FindSpawnLocation()
	{
		FVector SpawnLocation = SpawnPosition.Location;
		SpawnLocation.Y = Math::RandRange(-SpawnSize, SpawnSize);
		return SpawnLocation;
	}

	UFUNCTION()
	void GameStart()
	{
		SetActorTickEnabled(true);
		if (ZombieSequence.IsEmpty())
		{
			SpawnSequenceDT.GetAllRows(ZombieSequence);
			ZombieSequence.Sort();
			endTimer = ZombieSequence.Last().TimeMark;
			for (int i = 0; i < ZombieSequence.Num(); i++)
			{
				if (ZombieSequence[i].SpawnType != ESpawnType::Zombie)
				{
					ZombieSequence.RemoveAt(i);
					--i;
					continue;
				}
			}
			for (int i = 0; i < ZombieSequence.Num(); i++)
			{
				if (!ZombieSequence[i].WaveWarning.IsEmpty())
				{
					float delay = Math::Clamp(ZombieSequence[i].TimeMark - ZombieManager::WARNING_DURATION, 0, 999);
					if (delay == 0)
					{
						ShowWarning();
					}
					else
					{
						System::SetTimer(this, n"ShowWarning", delay, false);
					}
					break;
				}
			}
		}
	}

	UFUNCTION()
	void GamePause()
	{
		SetActorTickEnabled(false);
	}

	UFUNCTION()
	void GameEnd()
	{
		DOnClearedAllZombies.ExecuteIfBound();
		SetActorTickEnabled(false);
	}

	UFUNCTION()
	void UpdateZombieList(FName zombieNameToRemove)
	{
		if (SpawnedZombieList.Num() > 0)
		{
			SpawnedZombieList.Remove(zombieNameToRemove);
			if (SpawnedZombieList.Num() == 0 && CurrentLevelProgress >= 1)
			{
				System::SetTimer(this, n"GameEnd", 3, false);
			}
		}
	}

	void UpdateProgress()
	{
		if (GameMode.LevelType == ELevelType::Standard)
		{
			if (CurrentLevelProgress < 1)
			{
				CurrentLevelProgress = currentGameTime / endTimer;
				if (CurrentLevelProgress > 1)
				{
					CurrentLevelProgress = 1;
				}
				DOnProgressChanged.ExecuteIfBound(CurrentLevelProgress);
			}
		}
	}

	UFUNCTION()
	void ShowWarning()
	{
		if (nextSequenceMilestone < ZombieSequence.Num() && !ZombieSequence[nextSequenceMilestone].WaveWarning.IsEmpty())
		{
			if (ZombieSequence[nextSequenceMilestone].bDataOnly)
			{
				DShowBossMsg.ExecuteIfBound(ZombieSequence[nextSequenceMilestone].WaveWarning);
			}
			else
			{
				DShowWarning.ExecuteIfBound(ZombieSequence[nextSequenceMilestone].WaveWarning);
			}
		}
		else
		{
			DShowWarning.ExecuteIfBound(FText());
		}
		for (int i = nextSequenceMilestone + 1; i < ZombieSequence.Num(); i++)
		{
			if (!ZombieSequence[i].WaveWarning.IsEmpty())
			{
				System::SetTimer(this, n"ShowWarning", Math::Clamp(ZombieSequence[i].TimeMark - ZombieManager::WARNING_DURATION - currentGameTime, 0.01, 999), false);
				break; // Get out of the loop
			}
		}
	}
}
