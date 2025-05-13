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

	FVoidEvent OnLeftClicked;
	FVoidEvent OnRightClicked;
	FVoidEvent OnNextClicked;

	bool bIsLeft = false;

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
	}

	UFUNCTION()
	void Start()
	{
		int Count = Math::RandRange(2, 3);
		RandomLeftSide(Count);
		RandomRightSide(Count);
		RandomMid(Count);
	}

	UFUNCTION()
	void RandomLeftSide(int LeftCount = 0)
	{
		DataToUI(NormalEleArray[Math::RandRange(0, NormalEleArray.Num() - 1)], LeftStop0);
		DataToUI(NormalEleArray[Math::RandRange(0, NormalEleArray.Num() - 1)], LeftStop1);
		DataToUI(NormalEleArray[Math::RandRange(0, NormalEleArray.Num() - 1)], LeftStop2);

		LeftStop0.SetZombieMark(Math::RandBool(), NormalZombieIcon, Math::RandRange(0.2, 0.3));
		LeftStop1.SetZombieMark(Math::RandBool(), NormalZombieIcon, Math::RandRange(0.6, 0.7));
		LeftStop2.SetZombieMark(Math::RandBool(), NormalZombieIcon, Math::RandRange(1, 1.1));

		LeftStop0.SetActive(true, LeftCount >= 1 ? false : true);
		LeftStop1.SetActive(true, LeftCount >= 2 ? false : true);
		LeftStop2.SetActive(true, LeftCount >= 3 ? false : true);
	}

	UFUNCTION()
	void RandomRightSide(int RightCount = 0)
	{
		DataToUI(NormalEleArray[Math::RandRange(0, NormalEleArray.Num() - 1)], RightStop0);
		DataToUI(NormalEleArray[Math::RandRange(0, NormalEleArray.Num() - 1)], RightStop1);
		DataToUI(NormalEleArray[Math::RandRange(0, NormalEleArray.Num() - 1)], RightStop2);

		RightStop0.SetZombieMark(Math::RandBool(), NormalZombieIcon, Math::RandRange(0.2, 0.3));
		RightStop1.SetZombieMark(Math::RandBool(), NormalZombieIcon, Math::RandRange(0.6, 0.7));
		RightStop2.SetZombieMark(Math::RandBool(), NormalZombieIcon, Math::RandRange(1, 1.1));

		RightStop0.SetActive(true, RightCount >= 1 ? false : true);
		RightStop1.SetActive(true, RightCount >= 2 ? false : true);
		RightStop2.SetActive(true, RightCount >= 3 ? false : true);
	}

	UFUNCTION()
	void RandomMid(int OtherCount = 0)
	{
		DataToUI(EliteEleArray[Math::RandRange(0, EliteEleArray.Num() - 1)], MidStop0);
		DataToUI(BossEleArray[Math::RandRange(0, BossEleArray.Num() - 1)], LastStop);

		MidStop0.SetZombieMark(true, EliteZombieIcon, Math::RandRange(OtherCount * 0.25, OtherCount * 0.3), ELITE_ICON_SIZE);
		LastStop.SetZombieMark(true, BossZombieIcon, Math::RandRange(OtherCount * 0.4, OtherCount * 0.45), BOSS_ICON_SIZE);

		MidStop0.SetActive(true);
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

		OnRightClicked.Broadcast();
	}

	UFUNCTION()
	private void NextButtonClicked()
	{
		NextButton.SetVisibility(ESlateVisibility::Hidden);
		PlayAnimation(bIsLeft ? NextLeftAnim : NextRightAnim);

		OnNextClicked.Broadcast();
	}

	UFUNCTION(BlueprintOverride)
	void OnAnimationFinished(const UWidgetAnimation Animation)
	{
		if (Animation == PickLeftAnim || Animation == PickRightAnim)
		{
			NextButton.SetVisibility(ESlateVisibility::Visible);
			PlayAnimation(UpAnim, 0, 0);
		}
	}

	UFUNCTION()
	void DataToUI(FGameplayTag MapElementID, UUIMapButton& Button)
	{
		FMapElementDT Row;
		if (AllEleMap.Find(MapElementID, Row))
		{
			Button.SetData(Row);
		}
	}
}