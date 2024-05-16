class ABowlingGameMode : AGameMode
/**
 * BowlingGameMode implements the core gameplay logic for a simple bowling game.
 *
 * It keeps track of the current score and health points, and raises events when they change.
 * It also has logic to determine when the player wins or loses the game.
 *
 * The class contains UPROPERTY declarations for the key gameplay variables,
 * d for the score/HP update events, and UFUNCTIONs that encapsulate
 * the core gameplay logic like increasing score, taking damage, winning and losing.
 */
{
	// Set DefaultPawn in blueprints
	UPROPERTY(BlueprintReadWrite)
	int Score;

	UPROPERTY(BlueprintReadWrite)
	float HP = 100;

	UPROPERTY(BlueprintReadWrite)
	int CoinTotal;

	FIntDelegate DOnUpdateScore;
	FFloatDelegate DOnUpdateHP;
	FVoidDelegate DOnWin;
	FVoidDelegate DOnLose;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIZombieGameplay> UIZombie;

	UPROPERTY()
	UDataTable LevelConfigsDT;

	UPROPERTY()
	FLevelConfigsDT LevelConfigsData;

	// TArray<ULevelSequence> LevelSequence;
	AZombieManager zombMangr;
	ABowlingPawn bowlPawn;
	UBowlingGameInstance gameInstance;

	UPROPERTY()
	TArray<ULevelSequence> SequenceAssets;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		zombMangr = Cast<AZombieManager>(Gameplay::GetActorOfClass(AZombieManager));
		bowlPawn = Cast<ABowlingPawn>(Gameplay::GetActorOfClass(ABowlingPawn));
		gameInstance = Cast<UBowlingGameInstance>(Gameplay::GetGameInstance());
		// gameInstance.CurrentLevel = 2;
		UUIZombieGameplay UserWidget = Cast<UUIZombieGameplay>(WidgetBlueprint::CreateWidget(UIZombie, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();
		// Widget::SetInputMode_GameAndUIEx(Gameplay::GetPlayerController(0));
		DOnUpdateScore.BindUFunction(UserWidget, n"UpdateScore");
		DOnUpdateHP.BindUFunction(UserWidget, n"UpdateHP");
		DOnWin.BindUFunction(UserWidget, n"WinUI");
		DOnLose.BindUFunction(UserWidget, n"LoseUI");

		// Reset UI;
		DOnUpdateScore.ExecuteIfBound(Score);
		DOnUpdateHP.ExecuteIfBound(HP);

		bowlPawn.DOnComboUpdate.BindUFunction(UserWidget, n"UpdateCombo");
		bowlPawn.DOnCooldownUpdate.BindUFunction(UserWidget, n"UpdateCooldownPercent");
		zombMangr.DOnProgressChanged.BindUFunction(UserWidget, n"UpdateLevelProgress");
		zombMangr.DOnWarning.BindUFunction(UserWidget, n"UpdateWarningText");

		LevelConfigsDT.FindRow(FName("Item_" + (gameInstance.CurrentLevel - 1)), LevelConfigsData);
		zombMangr.SpawnSize = LevelConfigsData.SpawnSize;
		zombMangr.SpawnSequenceDT = LevelConfigsData.SpawnSequenceDT;
		bowlPawn.ItemsConfig = LevelConfigsData.ItemConfigsDT;

		PauseGame();
		if (LevelConfigsData.Delay > 0)
		{
			System::SetTimer(this, n"StartGame", LevelConfigsData.Delay, false);
		}
		else
		{
			StartGame();
		}

		FLatentActionInfo LatentInfo;
		LatentInfo.CallbackTarget = this;
		LatentInfo.ExecutionFunction = n"PlaySequence";
		LatentInfo.Linkage = 0;
		LatentInfo.UUID = 1;

		switch (gameInstance.CurrentLevel)
		{
			case 1:
				Gameplay::LoadStreamLevel(n"M_Level1a", true, true, LatentInfo);
				// Cast<ALevelVariantSetsActor>(Gameplay::GetActorOfClass(ALevelVariantSetsActor)).SwitchOnVariantByName("Lane", "SingleLane");
				break;
			case 2:
				PlaySequence();
				break;
			case 3:
				Gameplay::LoadStreamLevel(n"M_Level3", true, true, LatentInfo);
				break;
			default:
		}
		// bool success;
		// ULevelStreamingDynamic::LoadLevelInstance("M_Level2", FVector::ZeroVector, FRotator::ZeroRotator, success).OnLevelLoaded.AddUFunction(this, n"PlaySequence");
	}

	UFUNCTION()
	void PlaySequence()
	{
		if (gameInstance.CurrentLevel <= SequenceAssets.Num() && SequenceAssets[gameInstance.CurrentLevel - 1] != nullptr)
		{
			ALevelSequenceActor LSActor;
			ULevelSequencePlayer::CreateLevelSequencePlayer(SequenceAssets[gameInstance.CurrentLevel - 1], FMovieSceneSequencePlaybackSettings(), LSActor).Play();
		}
	}

	UFUNCTION()
	void StartGame()
	{
		zombMangr.GameStart();
		bowlPawn.SetCooldownPercent(1);
	}

	void PauseGame()
	{
		zombMangr.GamePause();
		bowlPawn.SetCooldownPercent(-1);
	}

	UFUNCTION()
	void ScoreChange(FName actorName)
	{
		Score++;
		if (Score == 14)
		{
			Win();
		}
		DOnUpdateScore.ExecuteIfBound(Score);
	}

	UFUNCTION()
	void HPChange(float Damage, FName zombieName)
	{
		HP -= Damage;
		if (HP <= 0)
		{
			HP = 0;
			Lose();
		}
		DOnUpdateHP.ExecuteIfBound(HP);
		zombMangr.UpdateZombieList(zombieName);
	}

	UFUNCTION()
	void Win()
	{
		// Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
		DOnWin.ExecuteIfBound();
	}

	UFUNCTION()
	void Lose()
	{
		// Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
		DOnLose.ExecuteIfBound();
	}

	UFUNCTION(BlueprintCallable)
	void NextLevel()
	{
		gameInstance.CurrentLevel++;
		RestartGame();
	}

	UFUNCTION()
	void CoinGetHandler(int CoinValue)
	{
		CoinTotal += CoinValue;
	}
}
