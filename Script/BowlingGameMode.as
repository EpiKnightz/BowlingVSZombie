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
	float HP = 100;

	UPROPERTY(BlueprintReadWrite)
	int CoinTotal;

	FIntDelegate DOnUpdateScore;
	FFloatDelegate DOnUpdateHP;
	FVoidEvent EOnLose;
	FCardDTEvent EOnRewardCollected;
	FVoidEvent EOnEndGame;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIZombieGameplay> UIZombie;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIShop> UIShop;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIShop> UIRest;

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
	AWeaponsManager WeaponsManager;
	AAbilitiesManager AbilitiesManager;
	UBowlingGameInstance GameInst;
	EGameStatus GameStatus = EGameStatus::PreGame;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GameInst = Cast<UBowlingGameInstance>(GameInstance);
		SurvivorManager = Gameplay::GetActorOfClass(ASurvivorManager);
		PowerManager = Gameplay::GetActorOfClass(APowerManager);
		WeaponsManager = Gameplay::GetActorOfClass(AWeaponsManager);
		AbilitiesManager = Gameplay::GetActorOfClass(AAbilitiesManager);

		int ConfigRow = GameInst.CurrentLevel > LevelConfigsDT.Num() ?
							LevelConfigsDT.Num() - 1 :
							GameInst.CurrentLevel - 1;
		LevelConfigsDT.FindRow(FName("Item_" + ConfigRow), LevelConfigsData);

		switch (LevelConfigsData.LevelType)
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
	}

	void SetupBossGame()
	{
	}

	void SetupShopGame()
	{
		UUIShop UserWidget = Cast<UUIShop>(WidgetBlueprint::CreateWidget(UIShop, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();

		UserWidget.EOnShopItemBought.AddUFunction(GameInst, n"OnShopItemBought");
		UserWidget.DLeaveShop.BindUFunction(this, n"NextLevel");
		GameInst.EOnCoinChange.AddUFunction(UserWidget, n"InterpolateCoinChanges");

		TArray<FCardDT> ShopItemsData;
		for (auto Item : LevelConfigsData.SurvivorsPoolConfig.ItemTags)
		{
			ShopItemsData.Add(FCardDT(SurvivorManager.GetSurvivorData(Item)));
		}
		for (auto Item : LevelConfigsData.WeaponsPoolConfig.ItemTags)
		{
			ShopItemsData.Add(FCardDT(WeaponsManager.GetWeaponData(Item)));
		}
		for (auto Item : LevelConfigsData.AbilitiesPoolConfig.ItemTags)
		{
			ShopItemsData.Add(FCardDT(AbilitiesManager.GetAbilityData(Item)));
		}
		for (auto Item : LevelConfigsData.PowerPoolConfig.ItemTags)
		{
			ShopItemsData.Add(FCardDT(PowerManager.GetPowerData(Item)));
		}

		UserWidget.SetShopData(ShopItemsData);
		UserWidget.SetInventoryCoin(GameInst.RunCoinTotal);
	}

	UFUNCTION()
	void SetupStandardGame()
	{
		ZombieManager = Gameplay::GetActorOfClass(AZombieManager);
		BoostManager = Gameplay::GetActorOfClass(ABoostManager);
		BowlingPawn = Gameplay::GetActorOfClass(ABowlingPawn);
		OptionCardManager = Gameplay::GetActorOfClass(AOptionCardManager);

		UUIZombieGameplay UserWidget = Cast<UUIZombieGameplay>(WidgetBlueprint::CreateWidget(UIZombie, Gameplay::GetPlayerController(0)));
		UserWidget.AddToViewport();

		// Widget::SetInputMode_GameAndUIEx(Gameplay::GetPlayerController(0));
		DOnUpdateScore.BindUFunction(UserWidget, n"UpdateScore");
		DOnUpdateHP.BindUFunction(UserWidget, n"UpdateHP");
		EOnLose.AddUFunction(UserWidget, n"LoseUI");
		EOnRewardCollected.AddUFunction(UserWidget, n"WinUI");
		EOnRewardCollected.AddUFunction(GameInst, n"AddRewards");
		EOnEndGame.AddUFunction(OptionCardManager, n"OnEndGame");
		EOnEndGame.AddUFunction(SurvivorManager, n"OnEndGame");
		EOnEndGame.AddUFunction(UserWidget, n"OnEndGame");

		// Reset UI;
		DOnUpdateScore.ExecuteIfBound(Score);
		DOnUpdateHP.ExecuteIfBound(HP);

		BowlingPawn.DOnComboUpdate.BindUFunction(UserWidget, n"UpdateCombo");
		BowlingPawn.EOnCooldownUpdate.AddUFunction(UserWidget, n"UpdateCooldownPercent");
		BowlingPawn.EOnBowlingSpawned.AddUFunction(PowerManager, n"ApplyBowlingPower");
		BowlingPawn.DBoostAttentionPercentage.BindUFunction(OptionCardManager, n"BoostAttentionBarPercent");

		ZombieManager.DOnProgressChanged.BindUFunction(UserWidget, n"UpdateLevelProgress");
		ZombieManager.DOnWarning.BindUFunction(UserWidget, n"UpdateWarningText");
		ZombieManager.DOnClearedAllZombies.BindUFunction(this, n"Win");
		ZombieManager.EOnZombieSpawned.AddUFunction(PowerManager, n"ApplyZombiePower");

		BoostManager.DOnWarning.BindUFunction(UserWidget, n"UpdateWarningText");

		SurvivorManager.EOnSurvivorSpawned.AddUFunction(PowerManager, n"ApplySurvivorPower");

		// /OptionCardManager.DCreateRandomSurvivor.BindUFunction(SurvivorManager, n"CreateRandomSurvior");
		OptionCardManager.EOnCardAdded.AddUFunction(SurvivorManager, n"AddCard");
		OptionCardManager.EOnCardAdded.AddUFunction(WeaponsManager, n"AddCard");
		OptionCardManager.DCreateSurvivorFromTag.BindUFunction(SurvivorManager, n"CreateSurvivorFromTag");
		OptionCardManager.DCreateWeaponFromTag.BindUFunction(WeaponsManager, n"CreateWeaponFromTag");
		OptionCardManager.DGetAbilityDataFromTag.BindUFunction(AbilitiesManager, n"GetAbilityData");
		OptionCardManager.EOnAttentionUpdate.AddUFunction(UserWidget, n"UpdateAttentionPercent");
		OptionCardManager.EOnAttentionFull.AddUFunction(UserWidget, n"OnAttentionFull");
		OptionCardManager.EOnAttentionStackUpdate.AddUFunction(UserWidget, n"UpdateAttentionStack");
		OptionCardManager.EOnDisableCardSpawn.AddUFunction(UserWidget, n"DisableCardSpawnUI");
		UserWidget.EOnAttentionClicked.AddUFunction(OptionCardManager, n"OnAttentionClicked");

		ZombieManager.SpawnSize = LevelConfigsData.SpawnSize;
		ZombieManager.SpawnSequenceDT = LevelConfigsData.SpawnSequenceDT;
		BoostManager.SpawnSequenceDT = LevelConfigsData.SpawnSequenceDT;
		BowlingPawn.ItemPoolConfig = LevelConfigsData.BowlingsPoolConfig;

		for (auto Item : LevelConfigsData.SurvivorsPoolConfig.ItemTags)
		{
			OptionCardManager.AddCard(FCardDT(Item, ECardType::Survivor));
		}
		for (auto Item : LevelConfigsData.WeaponsPoolConfig.ItemTags)
		{
			OptionCardManager.AddCard(FCardDT(Item, ECardType::Weapon));
		}
		for (auto Item : LevelConfigsData.AbilitiesPoolConfig.ItemTags)
		{
			OptionCardManager.AddCard(FCardDT(Item, ECardType::Ability));
		}

		PopulatePowerAndCards();

		if (LevelConfigsData.Delay > 0)
		{
			PauseGame();
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
		OptionCardManager.GameStart();
		BowlingPawn.SetCooldownPercent(1);
	}

	void PopulatePowerAndCards()
	{
		for (FCardDT Card : GameInst.CurrentCardInventory)
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
				FGameplayTag Reward = LevelConfigsData.GetRandomReward();
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
				EOnRewardCollected.Broadcast(RewardCard);
				// Todo: Move this to event maybe?
				GameInst.ChangeInvCoinAmount(CoinTotal);
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
		// TODO: This is for survival mode only, remove the hardcoded 15.
		if (Score == 15)
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
