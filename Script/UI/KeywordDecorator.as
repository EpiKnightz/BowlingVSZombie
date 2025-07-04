class UKeywordDecorator : ULinkRTBDecorator
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable EffectDataTable;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable KeywordDataTable;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIKeywordDescription> KeywordPopup;

	AUIManager UIManager;

	UFUNCTION(BlueprintOverride)
	void ClickEvent(FString idLink)
	{
		if (!IsValid(UIManager))
		{
			UIManager = Gameplay::GetActorOfClass(AUIManager);
		}
		APlayerController PlayerController = Gameplay::GetPlayerController(0);
		auto UserWidget = Cast<UUIKeywordDescription>(WidgetBlueprint::CreateWidget(KeywordPopup, PlayerController));
		UserWidget.Setup();
		UserWidget.DGetNameFromTag.BindUFunction(UIManager, n"GetKeywordName");

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
		if (!Result.IsEmptyOrWhitespace())
		{
			Result = FText::FromString("[" + Result + "]");
		}
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

	UFUNCTION(BlueprintOverride)
	int CheckTextStyle(FString idLink)
	{
		// FStatusDT StatusRow;
		// if (EffectDataTable.FindRow(FName(idLink), StatusRow))
		// {
		// 	return ELinkStyle::EffectStyle;
		// }
		// else
		// {
		// 	FKeywordDT KeywordRow;
		// 	if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
		// 	{
		// 		return ELinkStyle::KeywordStyle;
		// 	}
		// 	else
		// 	{
		// 		PrintError("GetStyle Keyword not found: " + idLink);
		// 		return ELinkStyle::Default;
		// 	}
		// }
		return -1;
	}

	UFUNCTION(BlueprintOverride)
	int CheckButtonStyle(FString idLink)
	{
		return -1;
	}

	UFUNCTION(BlueprintOverride)
	bool CheckTextFirst(FString idLink)
	{
		return true;
	}
}