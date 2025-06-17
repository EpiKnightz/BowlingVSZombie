const float NORMAL_ICON_SIZE = 50;
const float ELITE_ICON_SIZE = 75;
const float BOSS_ICON_SIZE = 120;
class UUIMap : UUserWidget
{
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation LeftAnim;
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation RightAnim;
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation UpAnim;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation PickRightAnim;
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation PickLeftAnim;
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation NextRightAnim;
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation NextLeftAnim;

	UPROPERTY(BindWidget)
	UUIMapButton LeftStop0;
	UPROPERTY(BindWidget)
	UUIMapButton LeftStop1;
	UPROPERTY(BindWidget)
	UUIMapButton LeftStop2;

	UPROPERTY(BindWidget)
	UUIMapButton RightStop0;
	UPROPERTY(BindWidget)
	UUIMapButton RightStop1;
	UPROPERTY(BindWidget)
	UUIMapButton RightStop2;

	UPROPERTY(BindWidget)
	UUIMapButton MidStop0;
	UPROPERTY(BindWidget)
	UUIMapButton LastStop;

	UPROPERTY(BindWidget)
	UButton LeftButton;
	UPROPERTY(BindWidget)
	UButton RightButton;
	UPROPERTY(BindWidget)
	UButton NextButton;

	UPROPERTY()
	UTexture2D NormalZombieIcon;
	UPROPERTY()
	UTexture2D EliteZombieIcon;
	UPROPERTY()
	UTexture2D BossZombieIcon;

	UPROPERTY(BlueprintReadWrite)
	UDataTable MapElementDataTable;
	TMap<FGameplayTag, FMapElementDT> AllEleMap;
	TArray<FGameplayTag> NormalEleArray;
	TArray<FGameplayTag> EliteEleArray;
	TArray<FGameplayTag> BossEleArray;
	TArray<UUIMapButton> AllStopArray;

	FVoidEvent OnLeftClicked;
	FVoidEvent OnRightClicked;
	FVoidEvent OnNextClicked;

	UBowlingGameInstance GameInst;
	FRandomStream MapRandomStream;
	int MapSeed = -1;

	bool bIsLeft = false;

	// Map position
	//     8
	// 1       4
	// 2   7   5
	// 3       6
	// 	   0 - Initial position

	// If current level and clear level are the same, open the map
	// If not, open the level directly

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		PlayAnimation(LeftAnim, 0, 0);
		PlayAnimation(RightAnim, 0, 0);
		TArray<FMapElementDT> MapElementArray;
		MapElementDataTable.GetAllRows(MapElementArray);
		for (FMapElementDT MapElement : MapElementArray)
		{
			AllEleMap.Add(MapElement.MapElementID, MapElement);
			if (MapElement.Type == EMapElement::Boss)
			{
				BossEleArray.Add(MapElement.MapElementID);
			}
			else if (MapElement.Type == EMapElement::Elite)
			{
				EliteEleArray.Add(MapElement.MapElementID);
			}
			else
			{
				NormalEleArray.Add(MapElement.MapElementID);
			}
		}

		NextButton.SetVisibility(ESlateVisibility::Hidden);

		LeftButton.OnClicked.AddUFunction(this, n"LeftButtonClicked");
		RightButton.OnClicked.AddUFunction(this, n"RightButtonClicked");
		NextButton.OnClicked.AddUFunction(this, n"NextButtonClicked");

		GameInst = Cast<UBowlingGameInstance>(GameInstance);

		// ToDo: Remove this from UI
		// if (GameInst.RunData.InitialSeed == -1)
		{
			MapRandomStream.GenerateNewSeed();
			MapSeed = MapRandomStream.GetInitialSeed();
			GameInst.SaveSeed(MapSeed);
			Print("Map Seed: " + MapSeed);
		}
		// MapRandomStream.Initialize(MapSeed);
	}

	UFUNCTION()
	void Start()
	{
		int Count = MapRandomStream.RandRange(2, 3);
		AllStopArray.Add(LeftStop0);
		AllStopArray.Add(LeftStop1);
		AllStopArray.Add(LeftStop2);
		AllStopArray.Add(RightStop0);
		AllStopArray.Add(RightStop1);
		AllStopArray.Add(RightStop2);
		AllStopArray.Add(MidStop0);
		AllStopArray.Add(LastStop);
		if (GameInst.RunData.RunTags.HasTag(GameplayTags::Map_Tutorial))
		{
			SetupTutorial();
		}
		else
		{
			RandomLeftSide(Count);
			RandomRightSide(Count);
			RandomMid(Count);
		}
		for (int i = 0; i < AllStopArray.Num(); i++)
		{
			AllStopArray[i].SetLock(true);
		}
		if (GameInst.RunData.CurrentLevel == 1
			|| GameInst.RunData.CurrentLevel == 2
			|| GameInst.RunData.CurrentLevel == 3)
		{
			LeftButtonClicked();
		}
		else if (GameInst.RunData.CurrentLevel == 4
				 || GameInst.RunData.CurrentLevel == 5
				 || GameInst.RunData.CurrentLevel == 6)
		{
			RightButtonClicked();
		}
		else if (GameInst.RunData.CurrentLevel == 7)
		{
			if (GameInst.RunData.ClearedLevels.Last() == 1
				|| GameInst.RunData.ClearedLevels.Last() == 2
				|| GameInst.RunData.ClearedLevels.Last() == 3)
			{
				LeftButtonClicked();
			}
			else
			{
				RightButtonClicked();
			}
		}
		else if (GameInst.RunData.CurrentLevel == 8)
		{
			NextButtonClicked();
		}
		System::SetTimer(this, n"PullClearData", 1.2, false);
	}

	void SetupStop(UUIMapButton& Stop, FGameplayTag MapElementID, int MapPos, bool bIsZombied, UTexture2D ZombieIcon, float AnimDelay, bool bIsActive, bool bIsHidden, FName ClickFuntion = NAME_None, float32 IconSize = NORMAL_ICON_SIZE)
	{
		DataToUI(MapElementID, Stop, MapPos);
		Stop.SetZombieMark(bIsZombied, ZombieIcon, AnimDelay, IconSize);
		Stop.SetActive(bIsActive, bIsHidden);
		if (ClickFuntion != NAME_None)
		{
			Stop.OnLockClicked.BindUFunction(this, ClickFuntion);
		}
	}

	UFUNCTION()
	void RandomLeftSide(int LeftCount = 0)
	{
		TArray<int> RandomArray;
		int RetryMax = 6;

		for (int i = 0; i < 3; i++)
		{
			int RetryCount = 0;
			int Result = 0;
			while (RetryCount < RetryMax)
			{
				Result = MapRandomStream.RandRange(0, NormalEleArray.Num() - 1);
				if (i == 0 || Result != RandomArray[i - 1])
				{
					break;
				}
				RetryCount++;
			}
			RandomArray.Add(Result);
		}

		SetupStop(LeftStop0, NormalEleArray[RandomArray[0]], 1, Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.2, 0.3), true, LeftCount >= 1 ? false : true, n"LeftButtonClicked");
		SetupStop(LeftStop1, NormalEleArray[RandomArray[1]], 2, Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.6, 0.7), true, LeftCount >= 2 ? false : true, n"LeftButtonClicked");
		SetupStop(LeftStop2, NormalEleArray[RandomArray[2]], 3, Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(1, 1.1), true, LeftCount >= 3 ? false : true, n"LeftButtonClicked");
		// DataToUI(NormalEleArray[RandomArray[0]], LeftStop0, 1);
		// DataToUI(NormalEleArray[RandomArray[1]], LeftStop1, 2);
		// DataToUI(NormalEleArray[RandomArray[2]], LeftStop2, 3);

		// LeftStop0.SetZombieMark(Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.2, 0.3));
		// LeftStop1.SetZombieMark(Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.6, 0.7));
		// LeftStop2.SetZombieMark(Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(1, 1.1));

		// LeftStop0.SetActive(true, LeftCount >= 1 ? false : true);
		// LeftStop1.SetActive(true, LeftCount >= 2 ? false : true);
		// LeftStop2.SetActive(true, LeftCount >= 3 ? false : true);
	}

	UFUNCTION()
	void RandomRightSide(int RightCount = 0)
	{
		TArray<int> RandomArray;
		int RetryMax = 6;

		for (int i = 0; i < 3; i++)
		{
			int RetryCount = 0;
			int Result = 0;
			while (RetryCount < RetryMax)
			{
				Result = MapRandomStream.RandRange(0, NormalEleArray.Num() - 1);
				if (i == 0 || Result != RandomArray[i - 1])
				{
					break;
				}
				RetryCount++;
			}
			RandomArray.Add(Result);
		}

		SetupStop(RightStop0, NormalEleArray[RandomArray[0]], 4, Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.2, 0.3), true, RightCount >= 1 ? false : true, n"RightButtonClicked");
		SetupStop(RightStop1, NormalEleArray[RandomArray[1]], 5, Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.6, 0.7), true, RightCount >= 2 ? false : true, n"RightButtonClicked");
		SetupStop(RightStop2, NormalEleArray[RandomArray[2]], 6, Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(1, 1.1), true, RightCount >= 3 ? false : true, n"RightButtonClicked");
		// DataToUI(NormalEleArray[RandomArray[0]], RightStop0, 4);
		// DataToUI(NormalEleArray[RandomArray[1]], RightStop1, 5);
		// DataToUI(NormalEleArray[RandomArray[2]], RightStop2, 6);

		// RightStop0.SetZombieMark(Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.2, 0.3));
		// RightStop1.SetZombieMark(Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(0.6, 0.7));
		// RightStop2.SetZombieMark(Math::RandomBoolFromStream(MapRandomStream), NormalZombieIcon, Math::RandRange(1, 1.1));

		// RightStop0.SetActive(true, RightCount >= 1 ? false : true);
		// RightStop1.SetActive(true, RightCount >= 2 ? false : true);
		// RightStop2.SetActive(true, RightCount >= 3 ? false : true);
	}

	UFUNCTION()
	void RandomMid(int OtherCount = 0)
	{
		SetupStop(MidStop0, EliteEleArray[MapRandomStream.RandRange(0, EliteEleArray.Num() - 1)], 7, true, EliteZombieIcon, Math::RandRange(OtherCount * 0.25, OtherCount * 0.3), true, false, NAME_None, ELITE_ICON_SIZE);
		SetupStop(LastStop, BossEleArray[MapRandomStream.RandRange(0, BossEleArray.Num() - 1)], 8, true, BossZombieIcon, Math::RandRange(OtherCount * 0.4, OtherCount * 0.45), true, false, NAME_None, BOSS_ICON_SIZE);
		// DataToUI(EliteEleArray[MapRandomStream.RandRange(0, EliteEleArray.Num() - 1)], MidStop0, 7);
		// DataToUI(BossEleArray[MapRandomStream.RandRange(0, BossEleArray.Num() - 1)], LastStop, 8);

		// MidStop0.SetZombieMark(true, EliteZombieIcon, Math::RandRange(OtherCount * 0.25, OtherCount * 0.3), ELITE_ICON_SIZE);
		// LastStop.SetZombieMark(true, BossZombieIcon, Math::RandRange(OtherCount * 0.4, OtherCount * 0.45), BOSS_ICON_SIZE);

		// MidStop0.SetActive(true);
	}

	UFUNCTION()
	void SetupTutorial()
	{
		SetupStop(LeftStop0, NormalEleArray[5], 1, true, NormalZombieIcon, Math::RandRange(0.2, 0.3), true, false, n"LeftButtonClicked");
		SetupStop(LeftStop1, NormalEleArray[2], 2, true, NormalZombieIcon, Math::RandRange(0.6, 0.7), true, false, n"LeftButtonClicked");
		SetupStop(LeftStop2, NormalEleArray[3], 3, false, NormalZombieIcon, Math::RandRange(1, 1.1), true, false, n"LeftButtonClicked");
		SetupStop(RightStop0, NormalEleArray[1], 4, true, NormalZombieIcon, Math::RandRange(0.2, 0.3), true, false, n"RightButtonClicked");
		SetupStop(RightStop1, NormalEleArray[0], 5, true, NormalZombieIcon, Math::RandRange(0.6, 0.7), true, false, n"RightButtonClicked");
		SetupStop(RightStop2, NormalEleArray[4], 6, false, NormalZombieIcon, Math::RandRange(1, 1.1), true, false, n"RightButtonClicked");
		SetupStop(MidStop0, EliteEleArray[0], 7, true, EliteZombieIcon, Math::RandRange(0.75, 0.9), true, false, NAME_None, ELITE_ICON_SIZE);
		SetupStop(LastStop, BossEleArray[0], 8, true, BossZombieIcon, Math::RandRange(1.2, 1.35), true, false, NAME_None, BOSS_ICON_SIZE);
	}

	UFUNCTION()
	void PullClearData()
	{
		UpdateClearStatus(GameInst.RunData.ClearedLevels);
	}

	void UpdateClearStatus(TArray<int> ClearLevels)
	{
		for (int i = 0; i < ClearLevels.Num(); i++)
		{
			if (ClearLevels[i] > 0)
			{
				AllStopArray[ClearLevels[i] - 1].SetClear(true);
			}
		}
	}

	UFUNCTION()
	private void LeftButtonClicked()
	{
		bIsLeft = true;
		LeftButton.SetVisibility(ESlateVisibility::Hidden);
		RightButton.SetVisibility(ESlateVisibility::Hidden);
		PlayAnimation(PickLeftAnim);
		RightStop0.SetActive(false);
		RightStop1.SetActive(false);
		RightStop2.SetActive(false);

		LeftStop0.SetLock(false);
		LeftStop1.SetLock(false);
		LeftStop2.SetLock(false);
		MidStop0.SetLock(false);

		OnLeftClicked.Broadcast();
	}

	UFUNCTION()
	private void RightButtonClicked()
	{
		bIsLeft = false;
		LeftButton.SetVisibility(ESlateVisibility::Hidden);
		RightButton.SetVisibility(ESlateVisibility::Hidden);
		PlayAnimation(PickRightAnim);
		LeftStop0.SetActive(false);
		LeftStop1.SetActive(false);
		LeftStop2.SetActive(false);

		RightStop0.SetLock(false);
		RightStop1.SetLock(false);
		RightStop2.SetLock(false);
		MidStop0.SetLock(false);

		OnRightClicked.Broadcast();
	}

	UFUNCTION()
	private void NextButtonClicked()
	{
		NextButton.SetVisibility(ESlateVisibility::Hidden);
		PlayAnimation(bIsLeft ? NextLeftAnim : NextRightAnim);

		LastStop.SetLock(false);

		OnNextClicked.Broadcast();
	}

	UFUNCTION(BlueprintOverride)
	void OnAnimationFinished(const UWidgetAnimation Animation)
	{
		if (Animation == PickLeftAnim || Animation == PickRightAnim)
		{
			// Move this when elite is defeated
			// NextButton.SetVisibility(ESlateVisibility::Visible);
			PlayAnimation(UpAnim, 0, 0);
		}
	}

	UFUNCTION()
	void DataToUI(FGameplayTag MapElementID, UUIMapButton& Button, int MapPosition)
	{
		FMapElementDT Row;
		if (AllEleMap.Find(MapElementID, Row))
		{
			Button.SetData(Row, MapPosition);
		}
	}
}