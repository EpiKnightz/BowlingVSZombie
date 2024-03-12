delegate void FScoreChangeDelegate(int NewScore);
delegate void FHPChangedDelegate(int NewHP);
delegate void FWinDelegate();
delegate void FLoseDelegate();
class ABowlingGameMode : AGameModeBase
/**
 * BowlingGameMode implements the core gameplay logic for a simple bowling game.
 *
 * It keeps track of the current score and health points, and raises events when they change.
 * It also has logic to determine when the player wins or loses the game.
 *
 * The class contains UPROPERTY declarations for the key gameplay variables,
 * delegates for the score/HP update events, and UFUNCTIONs that encapsulate
 * the core gameplay logic like increasing score, taking damage, winning and losing.
 */
{
	// Set DefaultPawn in blueprints
	UPROPERTY(BlueprintReadWrite)
	int Score;

	UPROPERTY(BlueprintReadWrite)
	int HP = 100;

	UPROPERTY(BlueprintReadWrite)
	float DelayTime = 5;

	FScoreChangeDelegate EventUpdateScore;
	FHPChangedDelegate EventUpdateHP;
	FWinDelegate EventWin;
	FLoseDelegate EventLose;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIZombieGameplay> UIZombie;

	AZombieManager zombMangr;
	ABowlingPawn bowlPawn;
	UBowlingGameInstance gameInstance;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		zombMangr = Cast<AZombieManager>(Gameplay::GetActorOfClass(AZombieManager));
		bowlPawn = Cast<ABowlingPawn>(Gameplay::GetActorOfClass(ABowlingPawn));
		gameInstance = Cast<UBowlingGameInstance>(Gameplay::GetGameInstance());
		UUIZombieGameplay UserWidget = Cast<UUIZombieGameplay>(WidgetBlueprint::CreateWidget(UIZombie, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();
		// Widget::SetInputMode_GameAndUIEx(Gameplay::GetPlayerController(0));
		EventUpdateScore.BindUFunction(UserWidget, n"UpdateScore");
		EventUpdateHP.BindUFunction(UserWidget, n"UpdateHP");
		EventWin.BindUFunction(UserWidget, n"WinUI");
		EventLose.BindUFunction(UserWidget, n"LoseUI");

		// Reset UI;
		EventUpdateScore.ExecuteIfBound(Score);
		EventUpdateHP.ExecuteIfBound(HP);

		UserWidget.BowlingPawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		UserWidget.ZombieManager = Cast<AZombieManager>(Gameplay::GetActorOfClass(AZombieManager));

		UserWidget.BowlingPawn.ComboUpdateDelegate.BindUFunction(UserWidget, n"UpdateCombo");
		UserWidget.ZombieManager.ProgressChangedEvent.BindUFunction(UserWidget, n"UpdateLevelProgress");
		UserWidget.ZombieManager.WarningDelegate.BindUFunction(UserWidget, n"UpdateWarningText");

		System::SetTimer(this, n"StartGame", DelayTime, false);
		PauseGame();
		if (gameInstance.CurrentLevel == 1)
		{
			Cast<ALevelVariantSetsActor>(Gameplay::GetActorOfClass(ALevelVariantSetsActor)).SwitchOnVariantByName("Lane", "SingleLane");
			Cast<ALevelSequenceActor>(Gameplay::GetActorOfClass(ALevelSequenceActor)).SequencePlayer.Play();
		}
		else
		{
			Cast<ALevelVariantSetsActor>(Gameplay::GetActorOfClass(ALevelVariantSetsActor)).SwitchOnVariantByName("Lane", "FullLane");
			Cast<ALevelSequenceActor>(Gameplay::GetActorOfClass(ALevelSequenceActor)).SequencePlayer.Stop();
		}
	}

	UFUNCTION()
	void StartGame()
	{
		zombMangr.GameStart();
		bowlPawn.currentTouchCooldown = 0;
	}

	void PauseGame()
	{
		zombMangr.GamePause();
		bowlPawn.currentTouchCooldown = 999999;
	}

	UFUNCTION()
	void ScoreChange(FName actorName)
	{
		Score++;
		if (Score == 14)
		{
			Win();
		}
		EventUpdateScore.ExecuteIfBound(Score);
	}

	UFUNCTION()
	void HPChange(int Damage, FName zombieName)
	{
		HP -= Damage;
		if (HP <= 0)
		{
			HP = 0;
			Lose();
		}
		EventUpdateHP.ExecuteIfBound(HP);
		zombMangr.UpdateZombieList(zombieName);
	}

	UFUNCTION()
	void Win()
	{
		// Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
		EventWin.ExecuteIfBound();
	}

	UFUNCTION()
	void Lose()
	{
		// Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
		EventLose.ExecuteIfBound();
	}

	UFUNCTION(BlueprintCallable)
	void NextLevel()
	{
		gameInstance.CurrentLevel++;
		Gameplay::OpenLevel(n"M_ActionPhaseFinal");
	}
}
