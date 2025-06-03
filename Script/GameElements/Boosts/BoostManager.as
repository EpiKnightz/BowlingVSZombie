namespace PowerUpManager
{
	const float WARNING_DURATION = 2.5;
}

class ABoostManager : AActor
{
	UPROPERTY()
	TSubclassOf<ABoost> PowerUpTemplate;

	UPROPERTY()
	FTransform SpawnPosition;

	UPROPERTY()
	float SpawnSize;

	UPROPERTY(BlueprintReadWrite)
	UDataTable PowerUpDataTable;
	TMap<FGameplayTag, FCollectibleDT> PowerUpDataMap;

	UPROPERTY(BlueprintReadWrite)
	UDataTable EffectDataTable;

	TArray<FSpawnSequenceDT> SpawnSequence;
	TArray<FGameplayTag> PowerUpTagPool;
	AStatusManager StatusManager;

	UPROPERTY(BlueprintReadWrite)
	UDataTable SpawnSequenceDT;

	private float countdown = 1;
	private int currentSequenceMilestone = -1;
	private int nextSequenceMilestone = 0;
	private float currentGameTime;
	private int multipleSpawnCount = 0;

	FFTextDelegate DOnWarning;
	FIntDelegate DPlaySpecificSequence;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FCollectibleDT> PowerUpArray;
		PowerUpDataTable.GetAllRows(PowerUpArray);
		for (FCollectibleDT PowerUp : PowerUpArray)
		{
			PowerUpDataMap.Add(PowerUp.CollectibleID, PowerUp);
		}
		ActorTickEnabled = false;
	}

	void Setup(AStatusManager iStatusManager)
	{
		StatusManager = iStatusManager;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		countdown -= DeltaSeconds;
		currentGameTime += DeltaSeconds;
		if (nextSequenceMilestone < SpawnSequence.Num())
		{
			if (currentGameTime >= SpawnSequence[nextSequenceMilestone].TimeMark)
			{
				PowerUpTagPool = SpawnSequence[nextSequenceMilestone].SpawnTag;
				if (PowerUpTagPool.Num() > 0)
				{
					currentSequenceMilestone = nextSequenceMilestone;
					countdown = 0;
					nextSequenceMilestone++;
				}
				else
				{
					Print("PowerUpPoolID is empty");
				}
			}
		}
		if (countdown <= 0)
		{
			if (PowerUpTagPool.Num() > 0)
			{
				if (SpawnSequence[currentSequenceMilestone].bAllowMultipleSpawns)
				{
					multipleSpawnCount = Math::RandRange(SpawnSequence[currentSequenceMilestone].MinSpawnPerMulti,
														 SpawnSequence[currentSequenceMilestone].MaxSpawnPerMulti);
				}
				if (SpawnSequence[currentSequenceMilestone].SpawnType == ESpawnType::PowerUp)
				{
					SpawnPowerUp();
				}
				else if (SpawnSequence[currentSequenceMilestone].SpawnType == ESpawnType::Zone)
				{
					SpawnZone();
				}
				else if (SpawnSequence[currentSequenceMilestone].SpawnType == ESpawnType::Cutscene)
				{
					DPlaySpecificSequence.ExecuteIfBound(int(SpawnSequence[currentSequenceMilestone].MinWaveCooldown));
					countdown = 9999;
					return;
				}
				countdown = Math::RandRange(SpawnSequence[currentSequenceMilestone].MinWaveCooldown, SpawnSequence[currentSequenceMilestone].MaxWaveCooldown);
			}
		}
	}

	UFUNCTION()
	FCollectibleDT GetPowerUpData(FGameplayTag PowerUpTag)
	{
		FCollectibleDT PowerUp;
		if (PowerUpDataMap.Find(PowerUpTag, PowerUp) != false)
		{
			return PowerUp;
		}
		else
		{
			PrintError("GetPowerUpData: PowerUpID " + PowerUpTag + " not found");
			return PowerUp;
		}
	}

	UFUNCTION()
	void SpawnPowerUp()
	{
		FCollectibleDT Row = GetPowerUpData(PowerUpTagPool[Math::RandRange(0, PowerUpTagPool.Num() - 1)]);

		// FStatusDT EffectRow;
		// if (!Row.EffectID.IsEmpty())
		//{
		//   To-do: Currently only support 1 effect per powerup
		//	EffectRow = StatusManager.GetStatusData(Row.EffectID[0]);
		//}

		FVector SpawnLocation = SpawnPosition.Location;
		SpawnLocation.Y = Math::RandRange(-SpawnSize, SpawnSize);
		// SpawnLocation.Z *= Row.Scale.Z;

		ABoost SpawnedActor = Cast<ABoost>(SpawnActor(PowerUpTemplate, SpawnLocation, SpawnPosition.Rotator()));
		// SpawnedActor.Mesh.SetStaticMesh(Row.PowerUpModel);
		SpawnedActor.InitData(Row);

		if (multipleSpawnCount > 0)
		{
			multipleSpawnCount--;
			System::SetTimer(this, n"SpawnPowerUp", SpawnSequence[currentSequenceMilestone].MultipleSpawnInterval, false);
		}
	}

	UFUNCTION()
	void SpawnZone()
	{
		SpawnActor(SpawnSequence[currentSequenceMilestone].ZoneTemplate, SpawnSequence[currentSequenceMilestone].ZoneLocation);

		if (multipleSpawnCount > 0)
		{
			multipleSpawnCount--;
			System::SetTimer(this, n"SpawnZone", SpawnSequence[currentSequenceMilestone].MultipleSpawnInterval, false);
		}
	}

	UFUNCTION()
	void GameStart()
	{
		SetActorTickEnabled(true);
		SpawnSequenceDT.GetAllRows(SpawnSequence);
		SpawnSequence.Sort();
		for (int i = 0; i < SpawnSequence.Num(); i++)
		{
			if (SpawnSequence[i].SpawnType != ESpawnType::PowerUp
				&& SpawnSequence[i].SpawnType != ESpawnType::Zone
				&& SpawnSequence[i].SpawnType != ESpawnType::Cutscene)
			{
				SpawnSequence.RemoveAt(i);
				--i;
				continue;
			}
		}
		for (int i = 0; i < SpawnSequence.Num(); i++)
		{
			if (!SpawnSequence[i].WaveWarning.IsEmpty())
			{
				float delay = Math::Clamp(SpawnSequence[i].TimeMark - PowerUpManager::WARNING_DURATION, 0, 999);
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
	void ShowWarning()
	{
		if (nextSequenceMilestone < SpawnSequence.Num() && !SpawnSequence[nextSequenceMilestone].WaveWarning.IsEmpty())
		{
			DOnWarning.ExecuteIfBound(SpawnSequence[nextSequenceMilestone].WaveWarning);
		}
		else
		{
			DOnWarning.ExecuteIfBound(FText());
		}
		for (int i = nextSequenceMilestone + 1; i < SpawnSequence.Num(); i++)
		{
			if (!SpawnSequence[i].WaveWarning.IsEmpty())
			{
				System::SetTimer(this, n"ShowWarning", Math::Clamp(SpawnSequence[i].TimeMark - ZombieManager::WARNING_DURATION - currentGameTime, 0.01, 999), false);
				break;
			}
		}
	}
}
