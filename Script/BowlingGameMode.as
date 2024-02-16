delegate void OnScoreChanged(int NewScore);
delegate void OnHPChanged(int NewHP);
delegate void OnWin();
delegate void OnLose();
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

	OnScoreChanged EventUpdateScore;
	OnHPChanged EventUpdateHP;
	OnWin EventWin;
	OnLose EventLose;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIZombieGameplay> UIZombie;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
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

		System::SetTimer(this, n"StartGame", 5, false);
		PauseGame();
	}

	UFUNCTION()
	void StartGame()
	{
		AZombieManager zombMangr = Cast<AZombieManager>(Gameplay::GetActorOfClass(AZombieManager::StaticClass()));
		zombMangr.ActorTickEnabled = true;
		ABowlingPawn bowlPawn = Cast<ABowlingPawn>(Gameplay::GetActorOfClass(ABowlingPawn::StaticClass()));
		bowlPawn.currentTouchCooldown = 0;
	}

	void PauseGame()
	{
		AZombieManager zombMangr = Cast<AZombieManager>(Gameplay::GetActorOfClass(AZombieManager::StaticClass()));
		zombMangr.ActorTickEnabled = false;
		ABowlingPawn bowlPawn = Cast<ABowlingPawn>(Gameplay::GetActorOfClass(ABowlingPawn::StaticClass()));
		bowlPawn.currentTouchCooldown = 999999;
	}

	UFUNCTION()
	void ScoreChange()
	{
		Score++;
		if (Score == 14)
		{
			Win();
		}
		EventUpdateScore.ExecuteIfBound(Score);
	}

	UFUNCTION()
	void HPChange(int Damage)
	{
		HP -= Damage;
		if (HP <= 0)
		{
			HP = 0;
			Lose();
		}
		EventUpdateHP.ExecuteIfBound(HP);
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
}
