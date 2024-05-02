namespace PowerUpManager
{
	const float WARNING_DURATION = 2.5;
}

class APowerUpManager : AActor
{
	UPROPERTY()
	TSubclassOf<APowerUp> PowerUpTemplate;

	UPROPERTY()
	FTransform SpawnPosition;

	UPROPERTY()
	float SpawnSize;

	UPROPERTY(BlueprintReadWrite)
	UDataTable PowerUpDataTable;

	UPROPERTY(BlueprintReadWrite)
	UDataTable EffectDataTable;

	TArray<FSpawnSequenceDT> SpawnSequence;
	TArray<FName> PowerUpPoolID;

	UPROPERTY(BlueprintReadWrite)
	UDataTable SpawnSequenceDT;

	private float countdown = 1;
	private int currentSequenceMilestone = -1;
	private int nextSequenceMilestone = 0;
	private float currentGameTime;
	private int multipleSpawnCount = 0;

	FFTextDelegate DOnWarning;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// ActorTickEnabled = false;
		GameStart();
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
				PowerUpPoolID = SpawnSequence[nextSequenceMilestone].SpawnID;
				if (PowerUpPoolID.Num() > 0)
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
			if (PowerUpPoolID.Num() > 0)
			{
				if (SpawnSequence[currentSequenceMilestone].bAllowMultipleSpawns)
				{
					multipleSpawnCount = Math::RandRange(SpawnSequence[currentSequenceMilestone].MinSpawnPerMulti, SpawnSequence[currentSequenceMilestone].MaxSpawnPerMulti) - 1;
				}
				SpawnPowerUp();
				countdown = Math::RandRange(SpawnSequence[currentSequenceMilestone].MinWaveCooldown, SpawnSequence[currentSequenceMilestone].MaxWaveCooldown);
			}
		}
	}

	UFUNCTION()
	void SpawnPowerUp()
	{
		FCollectibleDT Row;
		FName PowerUpID = PowerUpPoolID[Math::RandRange(0, PowerUpPoolID.Num() - 1)];
		PowerUpDataTable.FindRow(PowerUpID, Row);

		FStatusDT EffectRow;
		if (!Row.EffectID.IsEmpty())
		{
			EffectDataTable.FindRow(Row.EffectID[0], EffectRow);
		}

		FVector SpawnLocation = SpawnPosition.Location;
		SpawnLocation.Y = Math::RandRange(-SpawnSize, SpawnSize);
		// SpawnLocation.Z *= Row.Scale.Z;

		APowerUp SpawnedActor = Cast<APowerUp>(SpawnActor(PowerUpTemplate, SpawnLocation, SpawnPosition.Rotator()));
		// SpawnedActor.Mesh.SetStaticMesh(Row.PowerUpModel);
		SpawnedActor.InitData(Row, EffectRow);
		// SpawnedActor.SetData(Row.HP, Row.Atk, Row.Dmg, Row.Speed, Row.AtkSpeed, Row.Scale, Row.CoinDropAmount);

		if (multipleSpawnCount > 0)
		{
			multipleSpawnCount--;
			System::SetTimer(this, n"SpawnPowerUp", SpawnSequence[currentSequenceMilestone].MultipleSpawnInterval, false);
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
			if (SpawnSequence[i].SpawnType != ESpawnType::PowerUp)
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
				float delay = Math::Clamp(SpawnSequence[i].TimeMark - ZombieManager::WARNING_DURATION, 0, 999);
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
