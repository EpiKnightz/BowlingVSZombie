delegate void UpdateScoreDelegate(int NewScore);
delegate void UpdateHPDelegate(int NewHP);
delegate void WinDelegate();
delegate void LoseDelegate();
class ABowlingGameMode : AGameModeBase
{
	// Set DefaultPawn in blueprints
	UPROPERTY(BlueprintReadWrite)
	int Score;

	UPROPERTY(BlueprintReadWrite)
	int HP = 100;

	UpdateScoreDelegate EventUpdateScore;
	UpdateHPDelegate EventUpdateHP;
	WinDelegate EventWin;
	LoseDelegate EventLose;

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
	}

	UFUNCTION()
	void ScoreUp()
	{
		Score++;
		if (Score >= 10)
		{
			Win();
		}
		EventUpdateScore.ExecuteIfBound(Score);
	}

	UFUNCTION()
	void HPLost(int Damage)
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
		Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
		EventWin.ExecuteIfBound();
	}

	UFUNCTION()
	void Lose()
	{
		Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
		EventLose.ExecuteIfBound();
	}
}
