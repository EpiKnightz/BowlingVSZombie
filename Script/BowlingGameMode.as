enum EGameStatus
{
	PreGame,
	Ongoing,
	PostGame,
	Win,
	Lose,
}

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
	FVoidEvent EOnRewardReceived;
	FVoidEvent EOnLose;
	FCardDTEvent EOnRewardCollected;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIZombieGameplay> UIZombie;

	UPROPERTY()
	UDataTable LevelConfigsDT;

	UPROPERTY()
	FLevelConfigsDT LevelConfigsData;

	UPROPERTY()
	TArray<ULevelSequence> OpeningSequenceAssets;

	UPROPERTY()
	ULevelSequence WinningSequence;

	UPROPERTY()
	TSubclassOf<ARewardChest> RewardChestBP;

	AZombieManager ZombieManager;
	ABoostManager BoostManager;
	ABowlingPawn BowlingPawn;
	AOptionCardManager OptionCardManager;
	ASurvivorManager SurvivorManager;
	APowerManager PowerManager;
	UBowlingGameInstance GameInst;
	EGameStatus GameStatus = EGameStatus::PreGame;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ZombieManager = Gameplay::GetActorOfClass(AZombieManager);
		BoostManager = Gameplay::GetActorOfClass(ABoostManager);
		BowlingPawn = Gameplay::GetActorOfClass(ABowlingPawn);
		OptionCardManager = Gameplay::GetActorOfClass(AOptionCardManager);
		SurvivorManager = Gameplay::GetActorOfClass(ASurvivorManager);
		PowerManager = Gameplay::GetActorOfClass(APowerManager);
		GameInst = Cast<UBowlingGameInstance>(GameInstance);
		// TODO: Load GameInst.CurrentPowers and apply to the cards.

		UUIZombieGameplay UserWidget = Cast<UUIZombieGameplay>(WidgetBlueprint::CreateWidget(UIZombie, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();
		// Widget::SetInputMode_GameAndUIEx(Gameplay::GetPlayerController(0));
		DOnUpdateScore.BindUFunction(UserWidget, n"UpdateScore");
		DOnUpdateHP.BindUFunction(UserWidget, n"UpdateHP");
		EOnRewardReceived.AddUFunction(UserWidget, n"WinUI");
		EOnLose.AddUFunction(UserWidget, n"LoseUI");
		EOnRewardCollected.AddUFunction(UserWidget.RewardUI, n"SetRewardData");
		EOnRewardCollected.AddUFunction(GameInst, n"AddRewards");
		// Reset UI;
		DOnUpdateScore.ExecuteIfBound(Score);
		DOnUpdateHP.ExecuteIfBound(HP);

		BowlingPawn.DOnComboUpdate.BindUFunction(UserWidget, n"UpdateCombo");
		BowlingPawn.EOnCooldownUpdate.AddUFunction(UserWidget, n"UpdateCooldownPercent");
		ZombieManager.DOnProgressChanged.BindUFunction(UserWidget, n"UpdateLevelProgress");
		ZombieManager.DOnWarning.BindUFunction(UserWidget, n"UpdateWarningText");
		ZombieManager.DOnClearedAllZombies.BindUFunction(this, n"Win");

		LevelConfigsDT.FindRow(FName("Item_" + (GameInst.CurrentLevel - 1)), LevelConfigsData);
		ZombieManager.SpawnSize = LevelConfigsData.SpawnSize;
		ZombieManager.SpawnSequenceDT = LevelConfigsData.SpawnSequenceDT;
		BoostManager.SpawnSequenceDT = LevelConfigsData.SpawnSequenceDT;
		BowlingPawn.ItemsConfig = LevelConfigsData.ItemConfigsDT;
		SurvivorManager.ItemsConfig = LevelConfigsData.SurvivorConfigsDT;

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
		LatentInfo.ExecutionFunction = n"PlayOpeningSequence";
		LatentInfo.Linkage = 0;
		LatentInfo.UUID = 1;

		switch (GameInst.CurrentLevel)
		{
			case 1:
				Gameplay::LoadStreamLevel(n"M_Level1a", true, true, LatentInfo);
				break;
			case 2:
				Gameplay::LoadStreamLevel(n"M_Level1a", true, true, LatentInfo);
				PlayOpeningSequence();
				break;
			case 3:
				Gameplay::LoadStreamLevel(n"M_Level3", true, true, LatentInfo);
				break;
			default:
		}
	}

	UFUNCTION()
	void PlayOpeningSequence()
	{
		if (GameInst.CurrentLevel <= OpeningSequenceAssets.Num() && OpeningSequenceAssets[GameInst.CurrentLevel - 1] != nullptr)
		{
			PlaySequence(OpeningSequenceAssets[GameInst.CurrentLevel - 1]);
		}
	}

	UFUNCTION()
	void PlaySequence(ULevelSequence Sequence)
	{
		ALevelSequenceActor LSActor;
		ULevelSequencePlayer::CreateLevelSequencePlayer(Sequence, FMovieSceneSequencePlaybackSettings(), LSActor).Play();
	}

	UFUNCTION()
	void StartGame()
	{
		GameStatus = EGameStatus::Ongoing;
		ZombieManager.GameStart();
		BoostManager.GameStart();
		if (!LevelConfigsData.SurvivorConfigsDT.ItemIDs.IsEmpty())
		{
			OptionCardManager.GameStart();
		}
		BowlingPawn.SetCooldownPercent(1);
	}

	void PauseGame()
	{
		ZombieManager.GamePause();
		BoostManager.GamePause();
		OptionCardManager.GamePause();
		BowlingPawn.SetCooldownPercent(-1);
	}

	void EndGame()
	{
		OptionCardManager.EndGame();
	}

	UFUNCTION()
	void PostEndgameEvents()
	{
		switch (GameStatus)
		{
			case EGameStatus::Win:
			{
				FCardDT Reward = PowerManager.GetPowerData(n"Item_0");
				EOnRewardCollected.Broadcast(Reward);
				EOnRewardReceived.Broadcast();
				break;
			}
			case EGameStatus::Lose:
				EOnLose.Broadcast();
				break;
			default:
				Print("No game status");
				break;
		}
	}

	UFUNCTION()
	void ScoreChange(FName ActorName)
	{
		Score++;
		if (Score == 14)
		{
			Win();
		}
		DOnUpdateScore.ExecuteIfBound(Score);
	}

	UFUNCTION()
	void HPChange(float Damage, FName ZombieName)
	{
		HP -= Damage;
		if (HP <= 0)
		{
			HP = 0;
			Lose();
		}
		DOnUpdateHP.ExecuteIfBound(HP);
		ZombieManager.UpdateZombieList(ZombieName);
	}

	UFUNCTION()
	void Win()
	{
		// TODO: Test. Make a proper endgame sequence here
		BowlingPawn.WinGameAnimation();
		PlaySequence(WinningSequence);
		auto RewardChest = SpawnActor(RewardChestBP);
		RewardChest.DOnRewardCollected.BindUFunction(this, n"PostEndgameEvents");
		GameStatus = EGameStatus::Win;
		EndGame();
		//  Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
	}

	UFUNCTION()
	void Lose()
	{
		GameStatus = EGameStatus::Lose;
		EndGame();
		PostEndgameEvents();
		// Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
	}

	UFUNCTION(BlueprintCallable)
	void NextLevel()
	{
		GameInst.CurrentLevel++;
		RestartGame();
	}

	UFUNCTION()
	void CoinGetHandler(int CoinValue)
	{
		CoinTotal += CoinValue;
	}
}
