class UUIMainMenu : UUserWidget
{
	UFUNCTION()
	void OnPlayClicked()
	{
		auto GameInst = Cast<UBowlingGameInstance>(GameInstance);
		if (IsValid(GameInst))
		{
			if (GameInst.RunData.CurrentLevel == 0
				|| GameInst.RunData.ClearedLevels.IsEmpty()
				|| GameInst.RunData.CurrentLevel == GameInst.RunData.ClearedLevels.Last())
			{
				// Open Map instead
				GameInst.ShowBoardUI().SkipMission();
			}
			else
			{
				Gameplay::OpenLevel(n"M_ActionPhaseFinal");
			}
		}
	}

	UFUNCTION()
	void OnOptionsClicked()
	{
		auto GameInst = Cast<UBowlingGameInstance>(GameInstance);
		if (IsValid(GameInst))
		{
			// Test
			GameInst.ResetSave();
		}
	}
};