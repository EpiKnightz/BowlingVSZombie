enum EGameStatus
{
	PreGame,
	Ongoing,
	PostGame,
	Win,
	Lose,
}

class ABowlingGameMode : AGameMode
{
	// Set DefaultPawn in blueprints
	UPROPERTY(BlueprintReadWrite)
	int Score;

	UPROPERTY(BlueprintReadWrite)
	float RunHP = 100;

	UPROPERTY(BlueprintReadWrite)
	int CoinTotal;

	FIntDelegate DOnUpdateScore;
	FFloatEvent EOnUpdateHP;
	FVoidEvent EOnLose;
	FCardDTEvent EOnRewardCollected;
	FVoidEvent EOnEndGame;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIZombieGameplay> UIZombie;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIBoard> UIBoard;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIShop> UIShop;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIRest> UIRest;

	UPROPERTY()
	UDataTable LevelConfigsDT;

	UPROPERTY()
	FLevelConfigsDT TutorialConfigsData;

	UPROPERTY()
	TArray<ULevelSequence> OpeningSequenceAssets;

	UPROPERTY()
	ULevelSequence WinningSequence;

	UPROPERTY()
	ULevelSequence BossIntroSequence;

	UPROPERTY()
	ULevelSequence EndBossIntroSequence;

	UPROPERTY()
	TSubclassOf<ARewardChest> RewardChestBP;

	AZombieManager ZombieManager;
	ABoostManager BoostManager;
	ABowlingPawn BowlingPawn;
	AOptionCardManager OptionCardManager;
	ASurvivorManager SurvivorManager;
	APowerManager PowerManager;
	AWeaponsManager WeaponsManager;
	AAbilitiesManager AbilitiesManager;
	AStatusManager StatusManager;
	AUIManager UIManager;
	AMissionManager MissionManager;
	AFMODAmbientSound BackgroundMusic;
	UBowlingGameInstance GameInst;
	EGameStatus GameStatus = EGameStatus::PreGame;
	ELevelType LevelType = ELevelType::Standard;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GameInst = Cast<UBowlingGameInstance>(GameInstance);
		SurvivorManager = Gameplay::GetActorOfClass(ASurvivorManager);
		PowerManager = Gameplay::GetActorOfClass(APowerManager);
		WeaponsManager = Gameplay::GetActorOfClass(AWeaponsManager);
		AbilitiesManager = Gameplay::GetActorOfClass(AAbilitiesManager);
		UIManager = Gameplay::GetActorOfClass(AUIManager);
		MissionManager = Gameplay::GetActorOfClass(AMissionManager);
		BackgroundMusic = Gameplay::GetActorOfClass(AFMODAmbientSound);

		BackgroundMusic.AudioComponent.SetVolume(0.25);
		// Load save here, if there is no save, create a new one

		int ConfigRow = GameInst.GetCurrentLevel() > LevelConfigsDT.Num() ?
							LevelConfigsDT.Num() - 1 :
							GameInst.GetCurrentLevel() - 1;
		LevelConfigsDT.FindRow(FName("Item_" + ConfigRow), TutorialConfigsData);
		RunHP = GameInst.GetCurrentRunHP();
		LevelType = TutorialConfigsData.LevelType;

		switch (LevelType)
		{
			case ELevelType::Boss:
				SetupBossGame();
				break;
			case ELevelType::Shop:
				SetupShopGame();
				break;
			case ELevelType::Rest:
				SetupRestGame();
				break;
			case ELevelType::Standard:
			default:
				SetupStandardGame();
				break;
		}
	}

	void SetupRestGame()
	{
		UUIRest UserWidget = Cast<UUIRest>(WidgetBlueprint::CreateWidget(UIRest, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();

		UserWidget.DRestoreRunHPPercent.BindUFunction(GameInst, n"RestoreRunHPPercent");
		UserWidget.DAddCardToInventory.BindUFunction(GameInst, n"AddCardToInventory");
		UserWidget.DChangeCoinTotal.BindUFunction(GameInst, n"ChangeInvCoinAmount");
		GameInst.EOnCoinChange.AddUFunction(UserWidget, n"InterpolateCoinChanges");
		UserWidget.DLeaveRest.BindUFunction(GameInst, n"NextLevel");

		TArray<FCardDT> WishingPoolData;
		AddCardsToPool(WishingPoolData);

		UserWidget.SetWishingPoolData(WishingPoolData);
		UserWidget.SetInventoryCoin(GameInst.GetRunCoinTotal());
	}

	void SetupBossGame()
	{
		SetupStandardGame();
	}

	void SetupShopGame()
	{
		UUIShop UserWidget = Cast<UUIShop>(WidgetBlueprint::CreateWidget(UIShop, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();

		UserWidget.EOnShopItemBought.AddUFunction(GameInst, n"OnShopItemBought");
		UserWidget.DLeaveShop.BindUFunction(GameInst, n"NextLevel");
		GameInst.EOnCoinChange.AddUFunction(UserWidget, n"InterpolateCoinChanges");

		TArray<FCardDT> ShopItemsData;
		AddCardsToPool(ShopItemsData);

		UserWidget.SetShopData(ShopItemsData);
		UserWidget.SetInventoryCoin(GameInst.GetRunCoinTotal());
	}

	void AddCardsToPool(TArray<FCardDT>& Pool)
	{
		for (auto Item : TutorialConfigsData.SurvivorsPoolConfig.ItemTags)
		{
			Pool.Add(FCardDT(SurvivorManager.GetSurvivorData(Item)));
		}
		for (auto Item : TutorialConfigsData.WeaponsPoolConfig.ItemTags)
		{
			Pool.Add(FCardDT(WeaponsManager.GetWeaponData(Item)));
		}
		for (auto Item : TutorialConfigsData.AbilitiesPoolConfig.ItemTags)
		{
			Pool.Add(FCardDT(AbilitiesManager.GetAbilityData(Item)));
		}
		for (auto Item : TutorialConfigsData.PowerPoolConfig.ItemTags)
		{
			Pool.Add(FCardDT(PowerManager.GetPowerData(Item)));
		}
	}

	UFUNCTION()
	void SetupStandardGame()
	{
		ZombieManager = Gameplay::GetActorOfClass(AZombieManager);
		BoostManager = Gameplay::GetActorOfClass(ABoostManager);
		BowlingPawn = Gameplay::GetActorOfClass(ABowlingPawn);
		OptionCardManager = Gameplay::GetActorOfClass(AOptionCardManager);
		StatusManager = Gameplay::GetActorOfClass(AStatusManager);

		UUIZombieGameplay UserWidget = Cast<UUIZombieGameplay>(WidgetBlueprint::CreateWidget(UIZombie, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();

		// Testing
		// ShowBoardUI();

		DOnUpdateScore.BindUFunction(UserWidget, n"UpdateScore");
		EOnUpdateHP.AddUFunction(UserWidget, n"UpdateHP");
		EOnLose.AddUFunction(UserWidget, n"LoseUI");
		EOnRewardCollected.AddUFunction(UserWidget, n"WinUI");
		EOnRewardCollected.AddUFunction(GameInst, n"AddCardToInventory");
		EOnEndGame.AddUFunction(OptionCardManager, n"OnEndGame");
		EOnEndGame.AddUFunction(SurvivorManager, n"OnEndGame");
		EOnEndGame.AddUFunction(UserWidget, n"OnEndGame");
		EOnEndGame.AddUFunction(this, n"OnEndGame");

		// Reset UI;
		DOnUpdateScore.ExecuteIfBound(Score);
		EOnUpdateHP.Broadcast(RunHP);

		BowlingPawn.DOnComboUpdate.BindUFunction(UserWidget, n"UpdateCombo");
		BowlingPawn.EOnCooldownUpdate.AddUFunction(UserWidget, n"UpdateCooldownPercent");
		BowlingPawn.EOnBowlingSpawned.AddUFunction(PowerManager, n"ApplyBowlingPower");
		BowlingPawn.DBoostAttentionPercentage.BindUFunction(OptionCardManager, n"BoostAttentionBarPercent");

		ZombieManager.GameMode = this;
		ZombieManager.DOnProgressChanged.BindUFunction(UserWidget, n"UpdateLevelProgress");
		ZombieManager.DShowWarning.BindUFunction(UserWidget, n"UpdateWarningText");
		ZombieManager.DShowBossMsg.BindUFunction(UserWidget, n"UpdateBossText");
		ZombieManager.DOnClearedAllZombies.BindUFunction(this, n"Win");
		ZombieManager.EOnZombieSpawned.AddUFunction(PowerManager, n"ApplyZombiePower");
		ZombieManager.DAddZombieKillMission.BindUFunction(MissionManager, n"AddProgressToMissionTag");

		BoostManager.DOnWarning.BindUFunction(UserWidget, n"UpdateWarningText");
		BoostManager.Setup(StatusManager);
		BoostManager.DPlaySpecificSequence.BindUFunction(this, n"PlaySpecificSequence");

		SurvivorManager.EOnSurvivorSpawned.AddUFunction(PowerManager, n"ApplySurvivorPower");

		// /OptionCardManager.DCreateRandomSurvivor.BindUFunction(SurvivorManager, n"CreateRandomSurvior");
		OptionCardManager.EOnCardAdded.AddUFunction(SurvivorManager, n"AddCard");
		OptionCardManager.EOnCardAdded.AddUFunction(WeaponsManager, n"AddCard");
		OptionCardManager.DCreateSurvivorFromTag.BindUFunction(SurvivorManager, n"CreateSurvivorFromTag");
		OptionCardManager.DCreateWeaponFromTag.BindUFunction(WeaponsManager, n"CreateWeaponFromTag");
		OptionCardManager.DGetAbilityDataFromTag.BindUFunction(AbilitiesManager, n"GetAbilityData");
		OptionCardManager.DGetWeaponDataFromTag.BindUFunction(WeaponsManager, n"GetWeaponData");
		OptionCardManager.EOnAttentionUpdate.AddUFunction(UserWidget, n"UpdateAttentionPercent");
		OptionCardManager.EOnAttentionFull.AddUFunction(UserWidget, n"OnAttentionFull");
		OptionCardManager.EOnAttentionStackUpdate.AddUFunction(UserWidget, n"UpdateAttentionStack");
		OptionCardManager.EOnDisableCardSpawn.AddUFunction(UserWidget, n"DisableCardSpawnUI");
		UserWidget.EOnAttentionClicked.AddUFunction(OptionCardManager, n"OnAttentionClicked");

		ZombieManager.SpawnSize = TutorialConfigsData.SpawnSize;
		ZombieManager.SpawnSequenceDT = TutorialConfigsData.SpawnSequenceDT;
		BoostManager.SpawnSequenceDT = TutorialConfigsData.SpawnSequenceDT;
		BowlingPawn.ItemPoolConfig = TutorialConfigsData.BowlingsPoolConfig;

		for (auto Item : TutorialConfigsData.SurvivorsPoolConfig.ItemTags)
		{
			FCardDT CardDT(Item, ECardType::Survivor);
			OptionCardManager.AddCard(CardDT);
			GameInst.AddCardToInventory(CardDT);
		}
		for (auto Item : TutorialConfigsData.WeaponsPoolConfig.ItemTags)
		{
			FCardDT CardDT(Item, ECardType::Weapon);
			OptionCardManager.AddCard(CardDT);
			GameInst.AddCardToInventory(CardDT);
		}
		for (auto Item : TutorialConfigsData.AbilitiesPoolConfig.ItemTags)
		{
			FCardDT CardDT(Item, ECardType::Ability);
			OptionCardManager.AddCard(CardDT);
			GameInst.AddCardToInventory(CardDT);
		}

		PopulatePowerAndCards();

		if (TutorialConfigsData.Delay > 0)
		{
			PauseGame();
			System::SetTimer(this, n"StartGame", TutorialConfigsData.Delay, false);
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

		switch (GameInst.GetCurrentLevel())
		{
			case 1:
				Gameplay::LoadStreamLevel(n"M_Level1a", true, true, LatentInfo);
				break;
			case 2:
				Gameplay::LoadStreamLevel(n"M_Level1a", true, true, LatentInfo);
				// PlayOpeningSequence();
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
		int Idx = GameInst.GetCurrentLevel() - 1;
		if (GameInst.GetCurrentLevel() <= OpeningSequenceAssets.Num() && OpeningSequenceAssets[Idx] != nullptr)
		{
			PlaySequence(OpeningSequenceAssets[Idx]);
		}
	}

	UFUNCTION()
	void PlaySpecificSequence(int Idx)
	{
		if (Idx >= 0 && Idx < OpeningSequenceAssets.Num() && OpeningSequenceAssets[Idx] != nullptr)
		{
			PlaySequence(OpeningSequenceAssets[Idx]);
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
		OptionCardManager.GameStart();
		BowlingPawn.SetCooldownPercent(1);
	}

	void PopulatePowerAndCards()
	{
		for (FCardDT Card : GameInst.GetCurrentCardInventory())
		{
			switch (Card.CardType)
			{
				case ECardType::Power:
				{
					// TODO: Power always passive, so we don't need to check it
					if (Card.ItemID.MatchesTag(GameplayTags::Power_Passive))
					{
						PowerManager.AddPower(Card.ItemID);
					}
					break;
				}
				case ECardType::Bowling:
				{
					BowlingPawn.AddBowling(Card.ItemID);
					break;
				}
				case ECardType::Survivor:
				case ECardType::Weapon:
				case ECardType::Ability:
				{
					OptionCardManager.AddCard(Card);
					break;
				}
				default:
					break;
			}
		}
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
		EOnEndGame.Broadcast();
	}

	UFUNCTION()
	void PostEndgameEvents()
	{
		switch (GameStatus)
		{
			case EGameStatus::Win:
			{
				FGameplayTag Reward = TutorialConfigsData.GetRandomReward();
				FCardDT RewardCard;
				if (Reward.MatchesTag(GameplayTags::Power))
				{
					RewardCard = PowerManager.GetPowerData(Reward);
				}
				else if (Reward.MatchesTag(GameplayTags::Survivor))
				{
					RewardCard = SurvivorManager.GetSurvivorData(Reward);
				}
				else if (Reward.MatchesTag(GameplayTags::Weapon))
				{
					RewardCard = WeaponsManager.GetWeaponData(Reward);
				}
				else if (Reward.MatchesTag(GameplayTags::Ability))
				{
					RewardCard = AbilitiesManager.GetAbilityData(Reward);
				}
				else if (Reward.MatchesTag(GameplayTags::Bowling))
				{
					RewardCard = BowlingPawn.GetBowlingData(Reward);
				}
				EOnRewardCollected.Broadcast(RewardCard);
				// Todo: Move this to event maybe?
				GameInst.ChangeInvCoinAmount(CoinTotal);
				GameInst.SetRunHP(RunHP);
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
		Score += Math::Max(BowlingPawn.GetComboCounter(), 1);
		// // TODO: This is for survival mode only, remove the hardcoded 15.
		// if (ZombieManager.CurrentLevelProgress >=1 && )
		// {
		// 	Win();
		// }
		DOnUpdateScore.ExecuteIfBound(Score);
	}

	UFUNCTION()
	void HPChange(float Damage, FName ZombieName)
	{
		RunHP -= Damage;
		if (RunHP <= 0)
		{
			RunHP = 0;
			Lose();
		}
		EOnUpdateHP.Broadcast(RunHP);
		ZombieManager.UpdateZombieList(ZombieName);
	}

	UFUNCTION()
	void PlayZoomBossIntro(bool bIsStart)
	{
		if (bIsStart)
		{
			BowlingPawn.SetCooldownPercent(-1);
			PlaySequence(BossIntroSequence);
			PauseGame();
		}
		else
		{
			PlaySequence(EndBossIntroSequence);
			BowlingPawn.SetCooldownPercent(1);
			StartGame();
		}
	}

	UFUNCTION()
	private void UpdateMissionList(TArray<FAchievementData> Missions)
	{
	}

	UFUNCTION()
	private void OnEndGame()
	{

		BackgroundMusic.AudioComponent.Stop();
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
		GameInst.CompleteLevel();
		EndGame();
		Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
	}

	UFUNCTION()
	void Lose()
	{
		GameStatus = EGameStatus::Lose;
		EndGame();
		PostEndgameEvents();
		Widget::SetInputMode_UIOnlyEx(Gameplay::GetPlayerController(0));
	}

	// UFUNCTION(BlueprintCallable)
	// void NextLevel(int NextLevel = -1)
	// {
	// 	if (NextLevel == -1)
	// 	{
	// 		GameInst.SetCurrentLevel(GameInst.GetCurrentLevel() + 1);
	// 	}
	// 	else
	// 	{
	// 		GameInst.SetCurrentLevel(NextLevel);
	// 	}
	// 	GameInst.SaveRun();
	// 	RestartGame();
	// }

	UFUNCTION(BlueprintCallable)
	void ShowBoardUI()
	{
		MissionManager.EOnTutorialMissionUpdate.AddUFunction(GameInst.ShowBoardUI(), n"UpdateMissionList");
		MissionManager.UpdateTutorialMission();
	}

	UFUNCTION()
	void CoinGetHandler(int CoinValue)
	{
		CoinTotal += CoinValue;
	}
}
