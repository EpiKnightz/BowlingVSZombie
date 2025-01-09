class UKeywordDecorator : ULinkRTBDecorator
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable EffectDataTable;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable KeywordDataTable;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIKeywordDescription> KeywordPopup;

	// AUIManager UIManager;

	UFUNCTION(BlueprintOverride)
	void ClickEvent(FString idLink)
	{
		// if (!IsValid(UIManager))
		// {
		// 	UIManager = Gameplay::GetActorOfClass(AUIManager);
		// }
		APlayerController PlayerController = Gameplay::GetPlayerController(0);
		auto UserWidget = Cast<UUIKeywordDescription>(WidgetBlueprint::CreateWidget(KeywordPopup, PlayerController));
		UserWidget.SetDesiredSizeInViewport(FVector2D(300, 300));
		float32 MouseX = 0, MouseY = 0;
		PlayerController.GetMousePosition(MouseX, MouseY);
		UserWidget.SetPositionInViewport(FVector2D(MouseX, MouseY));

		FStatusDT StatusRow;
		if (EffectDataTable.FindRow(FName(idLink), StatusRow))
		{
			UserWidget.SetEffectDescription(StatusRow);
		}
		else
		{
			FKeywordDT KeywordRow;
			if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
			{
				UserWidget.SetKeywordDescription(KeywordRow);
			}
			else
			{
				PrintError("Keyword not found: " + idLink);
			}
		}
		UserWidget.AddToViewport();
		UserWidget.SetFocus();
		// UserWidget.DCheckAndRemoveWidgetsOfClass.BindUFunction(UIManager, n"CheckAndRemoveWidgetsOfClass");
		//  UserWidget.DCheckFocusOfClass.BindUFunction(UIManager, n"CheckFocusOfClass");
		//  UserWidget.DAddFocusWidget.BindUFunction(UIManager, n"AddFocusWidget");
		//  UserWidget.DRemoveFocusWidget.BindUFunction(UIManager, n"RemoveFocusWidget");
	}

	UFUNCTION(BlueprintOverride)
	FText FormatText(FString idLink)
	{
		FText Result;
		FStatusDT StatusRow;
		if (EffectDataTable.FindRow(FName(idLink), StatusRow))
		{
			Result = StatusRow.Name;
		}
		else
		{
			FKeywordDT KeywordRow;
			if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
			{
				Result = KeywordRow.Name;
			}
			else
			{
				return Result;
			}
		}
		Result = FText::FromString("[" + Result + "]");
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	UTexture2D FindIcon(FString idLink)
	{
		FStatusDT StatusRow;
		if (EffectDataTable.FindRow(FName(idLink), StatusRow))
		{
			return StatusRow.Icon;
		}
		else
		{
			FKeywordDT KeywordRow;
			if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
			{
				return KeywordRow.Icon;
			}
			else
			{
				return nullptr;
			}
		}
	}
}