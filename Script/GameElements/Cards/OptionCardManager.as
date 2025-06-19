const float TIME_SCALE_WHEN_SPAWNED_CARD = 0.05;
const int MAX_RANDOM_RETRY = 6;
const float STARTING_ATTENTION_BAR_PERCENT = 0.8;

class AOptionCardManager : AActor
{
	UPROPERTY()
	TSubclassOf<AOptionCard> CardTemplate;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor CommonColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor RareColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor EpicColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Rarity)
	FLinearColor LegendColor;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Element)
	FLinearColor FireColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Element)
	FLinearColor WaterColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Element)
	FLinearColor ForestColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Element)
	FLinearColor EarthColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Element)
	FLinearColor AetherColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Element)
	FLinearColor NetherColor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Element)
	FLinearColor VoidColor;

	// This is to display the card in the game, from left to right: 0, 1, 2
	int CurrentDisplayOrder = 0;
	FCardDT SelectedCardData;
	TMap<int, AOptionCard> CardDisplayOrderMap;
	int CurrentSelectionID = 0;
	TMap<int, FCardDT> CardInventory;

	private int LastSpawnedID = -1;
	private int SpawnWaveCount = 0;
	private float AttentionBarPercent = 0;
	private float AttentionFillRate = 0.05; // Equal to 20s to fill. TODO: Make this a data
	private int AttentionStack = 0;

	FTagSurvivor2DataDelegate DCreateSurvivorFromTag;
	FTagWeapon2DataDelegate DCreateWeaponFromTag;
	FTag2WeaponDataDelegate DGetWeaponDataFromTag;
	FTag2AbilityDataDelegate DGetAbilityDataFromTag;
	FCardDTEvent EOnCardAdded;
	FFloatEvent EOnAttentionUpdate;
	FVoidEvent EOnAttentionFull;
	FIntEvent EOnAttentionStackUpdate;
	FBoolEvent EOnDisableCardSpawn;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SetAttentionBarPercent(-1);
	}

	void GameStart()
	{
		if (CardInventory.IsEmpty())
		{
			EOnDisableCardSpawn.Broadcast(true);
			SetActorTickEnabled(false);
		}
		else
		{
			EOnDisableCardSpawn.Broadcast(false);
			SetAttentionBarPercent(0);
			SetActorTickEnabled(true);
		}
	}

	void GamePause()
	{
		SetActorTickEnabled(false);
		EOnDisableCardSpawn.Broadcast(true);
	}

	UFUNCTION()
	void OnEndGame()
	{
		System::ClearTimer(this, "SpawnCard");
		SetActorTickEnabled(false);
	}

	void AddCard(FCardDT Card)
	{
		CardInventory.Add(CurrentSelectionID, Card);
		CurrentSelectionID++;
		EOnCardAdded.Broadcast(Card);
	}

	void RemoveCard(int ID)
	{
		CardInventory.Remove(ID);
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (AttentionBarPercent >= 0 && AttentionBarPercent < 1)
		{
			BoostAttentionBarPercent(AttentionFillRate * DeltaSeconds);
		}
		else if (AttentionBarPercent >= 1)
		{
			EOnAttentionFull.Broadcast();
			BoostAttentionStack(1);
			SetAttentionBarPercent(0);
		}
	}

	UFUNCTION()
	void BoostAttentionBarPercent(float Boost)
	{
		SetAttentionBarPercent(AttentionBarPercent + Boost);
	}

	UFUNCTION()
	void SetAttentionBarPercent(float Percent)
	{
		AttentionBarPercent = Percent;
		EOnAttentionUpdate.Broadcast(AttentionBarPercent);
	}

	UFUNCTION()
	void BoostAttentionStack(int Boost)
	{
		SetAttentionStack(AttentionStack + Boost);
	}

	UFUNCTION()
	void SetAttentionStack(int Value)
	{
		AttentionStack = Value;
		EOnAttentionStackUpdate.Broadcast(AttentionStack);
	}

	UFUNCTION()
	void OnAttentionClicked()
	{
		if (AttentionStack > 0)
		{
			BoostAttentionStack(-1);
			SpawnCard();
		}
	}

	FCardDT GetRandomCard(ECardType ForceCardType = ECardType::None)
	{
		if (CardInventory.IsEmpty())
		{
			PrintWarning("CardInventory is empty");
			return FCardDT();
		}
		int NewSpawnedID = Math::RandRange(0, CardInventory.Num() - 1);
		// Retry until we get a different ID, or exceeded MAX_RANDOM_RETRY
		int CurrentRetry = 0;

		while (LastSpawnedID >= 0
			   && ((NewSpawnedID == LastSpawnedID || CardInventory[LastSpawnedID].ItemID == CardInventory[NewSpawnedID].ItemID)
				   || (ForceCardType != ECardType::None && CardInventory[NewSpawnedID].CardType != ForceCardType))
			   && CurrentRetry < MAX_RANDOM_RETRY
			   && CardInventory.Num() > 1)
		{
			NewSpawnedID = Math::RandRange(0, CardInventory.Num() - 1);
			CurrentRetry++;
		}
		if (CurrentRetry >= MAX_RANDOM_RETRY)
		{
			int ManualOffset = LastSpawnedID < CardInventory.Num() / 2.0 ? 1 : -1;
			if (ForceCardType == ECardType::None
				|| CardInventory[LastSpawnedID + ManualOffset].CardType == ForceCardType)
			{
				NewSpawnedID = LastSpawnedID + ManualOffset;
			}
			else
			{
				if (ManualOffset > 0
					&& LastSpawnedID > 0
					&& CardInventory[LastSpawnedID - ManualOffset].CardType == ForceCardType)
				{
					NewSpawnedID = LastSpawnedID - ManualOffset;
				}
				else if (ManualOffset < 0
						 && LastSpawnedID < CardInventory.Num() - 1
						 && CardInventory[LastSpawnedID - ManualOffset].CardType == ForceCardType)
				{
					NewSpawnedID = LastSpawnedID - ManualOffset;
				}
				else
				{
					Print("Random failed to find a card");
				}
			}
		}
		LastSpawnedID = NewSpawnedID;
		return CardInventory[NewSpawnedID];
	}

	UFUNCTION()
	void SpawnCard()
	{
		Widget::SetInputMode_GameAndUIEx(Gameplay::GetPlayerController(0));
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.DSetBowlingAimable.ExecuteIfBound(false);
		Gameplay::SetGlobalTimeDilation(TIME_SCALE_WHEN_SPAWNED_CARD);
		AOptionCard Card = SpawnActor(CardTemplate);
		Card.DOnCardClicked.BindUFunction(this, n"OnCardClicked");
		ECardType ForceCardType = ECardType::None;
		if (SpawnWaveCount == 0)
		{
			ForceCardType = ECardType::Survivor;
		}
		FCardDT ChosenCard = GetRandomCard(ForceCardType);
		Card.Init(CurrentDisplayOrder, this, ChosenCard);
		Card.SetCardColor(GetRarityColor(ChosenCard.Rarity), GetElementColor(ChosenCard.DescriptionTags));

		CardDisplayOrderMap.Add(CurrentDisplayOrder, Card);
		CurrentDisplayOrder++;
		if (CurrentDisplayOrder < 3)
		{
			System::SetTimer(this, n"SpawnCard", 0.5 * TIME_SCALE_WHEN_SPAWNED_CARD, false);
		}
		else
		{
			SpawnWaveCount++;
			LastSpawnedID = -1;
		}
	}

	UFUNCTION()
	void OnCardClicked(int DisplayOrder, FCardDT CardData)
	{
		SelectedCardData = CardData;
		for (int i = 0; i < CardDisplayOrderMap.Num(); i++)
		{
			if (i != DisplayOrder)
			{
				// Shouldn't it be Find only here?
				CardDisplayOrderMap.FindOrAdd(i).Outro();
			}
		}
	}

	UFUNCTION()
	void OnTargetChosen(AActor Target)
	{
		ASurvivor Survivor = Cast<ASurvivor>(Target);
		if (IsValid(Survivor))
		{
			if (SelectedCardData.CardType == ECardType::Weapon)
			{
				Survivor.ChangeWeapon(SelectedCardData.ItemID);
				Survivor.OnNewCardAdded();
			}
			else if (SelectedCardData.CardType == ECardType::Ability)
			{
				Survivor.AddAbility(SelectedCardData.ItemID);
				Survivor.OnNewCardAdded();
			}
		}
	}

	FLinearColor GetRarityColor(ERarity Rarity)
	{
		FLinearColor ReturnColor;
		switch (Rarity)
		{
			case ERarity::Common:
				ReturnColor = CommonColor;
				break;
			case ERarity::Rare:
				ReturnColor = RareColor;
				break;
			case ERarity::Epic:
				ReturnColor = EpicColor;
				break;
			case ERarity::Legendary:
				ReturnColor = LegendColor;
				break;
			default:
				ReturnColor = FLinearColor::DPink;
				break;
		}
		return ReturnColor;
	}

	TArray<FLinearColor> GetElementColor(FGameplayTagContainer DescriptionTags)
	{
		TArray<FLinearColor> ReturnColor;
		FGameplayTagContainer Filtered = DescriptionTags.Filter(GameplayTags::Description_Element.SingleTagContainer);
		if (Filtered.IsEmpty() || Filtered.Num() > 2)
		{
			ReturnColor.Add(FLinearColor::DPink);
			return ReturnColor;
		}
		if (DescriptionTags.HasTagExact(GameplayTags::Description_Element_Void))
		{
			ReturnColor.Add(VoidColor);
		}
		if (DescriptionTags.HasTagExact(GameplayTags::Description_Element_Nether))
		{
			ReturnColor.Add(NetherColor);
		}
		if (DescriptionTags.HasTagExact(GameplayTags::Description_Element_Aether))
		{
			ReturnColor.Add(AetherColor);
		}
		if (DescriptionTags.HasTagExact(GameplayTags::Description_Element_Earth))
		{
			ReturnColor.Add(EarthColor);
		}
		if (DescriptionTags.HasTagExact(GameplayTags::Description_Element_Forest))
		{
			ReturnColor.Add(ForestColor);
		}
		if (DescriptionTags.HasTagExact(GameplayTags::Description_Element_Water))
		{
			ReturnColor.Add(WaterColor);
		}
		if (DescriptionTags.HasTagExact(GameplayTags::Description_Element_Fire))
		{
			ReturnColor.Add(FireColor);
		}

		return ReturnColor;
	}

	UFUNCTION()
	private void OnAnyDragReleased()
	{
		if (CurrentDisplayOrder != 0)
		{
			CurrentDisplayOrder = 0;
			if (AttentionStack > 0)
			{
				OnAttentionClicked();
			}
		}
	}
};