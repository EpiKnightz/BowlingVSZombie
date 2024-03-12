delegate void OnProgressChanged(float NewProgress);
delegate void FWarningDelegate(FText Message);

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
	FTransform SpawnPosition;

	UPROPERTY()
	float SpawnSize;

	UPROPERTY(BlueprintReadWrite)
	UDataTable ZombieDataTable;

	TArray<FSpawnSequenceDT> ZombieSequence;
	TArray<FName> ZombiePoolID;
	TArray<FName> SpawnedZombieList;

	UPROPERTY(BlueprintReadWrite)
	UDataTable SpawnSequenceDT;

	private float countdown = 1;
	private int currentSequenceMilestone = -1;
	private int nextSequenceMilestone = 0;
	private float endTimer = 9999;
	private float currentGameTime;
	private int multipleSpawnCount = 0;

	UPROPERTY(BlueprintReadWrite)
	float CurrentLevelProgress = 0;

	OnProgressChanged ProgressChangedEvent;
	FWarningDelegate WarningDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorTickEnabled = false;
		SpawnSequenceDT.GetAllRows(ZombieSequence);
		ZombieSequence.Sort();
		endTimer = ZombieSequence.Last().TimeMark;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		countdown -= DeltaSeconds;
		currentGameTime += DeltaSeconds;
		if (currentGameTime >= endTimer)
		{
			if (ZombieSequence.Last().ZombieID.Num() == 1 && ZombieSequence.Last().ZombieID[0] == "End")
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
				ZombiePoolID = ZombieSequence[nextSequenceMilestone].ZombieID;
				if (ZombiePoolID.Num() > 0)
				{
					currentSequenceMilestone = nextSequenceMilestone;
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
			if (ZombiePoolID.Num() > 0)
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
	void SpawnZombie()
	{
		/**
		 * Spawns a random zombie from the ZombiePoolID array based on
		 * the provided zombie data table row. Sets the zombie's stats
		 * based on the data table values. Randomly selects a zombie
		 * model from the available options in the data table row.
		 */
		FZombieDT Row;
		FName ZombieID = ZombiePoolID[Math::RandRange(0, ZombiePoolID.Num() - 1)];
		ZombieDataTable.FindRow(ZombieID, Row);

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
		SpawnedZombieList.Add(SpawnedActor.GetName());

		ABowlingGameMode GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
		SpawnedActor.ZombDieEvent.BindUFunction(GM, n"ScoreChange");
		SpawnedActor.ZombDieEvent.BindUFunction(this, n"UpdateZombieList");
		SpawnedActor.ZombieReachEvent.BindUFunction(GM, n"HPChange");

		if (multipleSpawnCount > 0)
		{
			multipleSpawnCount--;
			System::SetTimer(this, n"SpawnZombie", ZombieSequence[currentSequenceMilestone].MultipleSpawnInterval, false);
		}
	}

	UFUNCTION()
	void GameStart()
	{
		SetActorTickEnabled(true);
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

	UFUNCTION()
	void GamePause()
	{
		SetActorTickEnabled(false);
	}

	UFUNCTION()
	void GameEnd()
	{
		Cast<ABowlingGameMode>(Gameplay::GetGameMode()).Win();
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
				GameEnd();
			}
		}
	}

	void UpdateProgress()
	{
		if (CurrentLevelProgress < 1)
		{
			CurrentLevelProgress = currentGameTime / endTimer;
			if (CurrentLevelProgress > 1)
			{
				CurrentLevelProgress = 1;
			}
			ProgressChangedEvent.ExecuteIfBound(CurrentLevelProgress);
		}
	}

	UFUNCTION()
	void ShowWarning()
	{
		if (nextSequenceMilestone < ZombieSequence.Num() && !ZombieSequence[nextSequenceMilestone].WaveWarning.IsEmpty())
		{
			WarningDelegate.ExecuteIfBound(ZombieSequence[nextSequenceMilestone].WaveWarning);
		}
		else
		{
			WarningDelegate.ExecuteIfBound(FText());
		}
		for (int i = nextSequenceMilestone + 1; i < ZombieSequence.Num(); i++)
		{
			if (!ZombieSequence[i].WaveWarning.IsEmpty())
			{
				System::SetTimer(this, n"ShowWarning", Math::Clamp(ZombieSequence[i].TimeMark - ZombieManager::WARNING_DURATION - currentGameTime, 0.01, 999), false);
				break;
			}
		}
	}
}
