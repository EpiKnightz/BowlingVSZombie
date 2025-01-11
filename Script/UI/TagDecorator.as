class UTagDecorator : ULinkRTBDecorator
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Data)
	UDataTable KeywordDataTable;

	UPROPERTY(BlueprintReadWrite)
	TSubclassOf<UUIKeywordDescription> KeywordPopup;

	UFUNCTION(BlueprintOverride)
	void ClickEvent(FString idLink)
	{
		FKeywordDT KeywordRow;
		if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
		{
			if (!KeywordRow.Description.IsEmptyOrWhitespace())
			{
				APlayerController PlayerController = Gameplay::GetPlayerController(0);
				auto UserWidget = Cast<UUIKeywordDescription>(WidgetBlueprint::CreateWidget(KeywordPopup, PlayerController));
				float32 MouseX = 0, MouseY = 0;
				PlayerController.GetMousePosition(MouseX, MouseY);
				int SizeX = 0, SizeY = 0;
				PlayerController.GetViewportSize(SizeX, SizeY);
				UserWidget.Setup(MouseX, MouseY, SizeX, SizeY);
				UserWidget.SetKeywordDescription(KeywordRow);
				UserWidget.AddToViewport();
				UserWidget.SetFocus();
			}
		}
		else
		{
			PrintError("Keyword not found: " + idLink);
		}
	}

	UFUNCTION(BlueprintOverride)
	FText FormatText(FString idLink)
	{
		FText Result;
		FKeywordDT KeywordRow;
		if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
		{
			if (KeywordRow.Description.IsEmptyOrWhitespace())
			{
				Result = KeywordRow.Name;
			}
			else
			{
				Result = KeywordRow.Name;
			}
		}
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	UTexture2D FindIcon(FString idLink)
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

	UFUNCTION(BlueprintOverride)
	int CheckTextStyle(FString idLink)
	{
		FKeywordDT KeywordRow;
		if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
		{
			if (KeywordRow.Description.IsEmptyOrWhitespace())
			{
				return 0;
			}
		}
		return -1;
	}

	UFUNCTION(BlueprintOverride)
	int CheckButtonStyle(FString idLink)
	{
		FKeywordDT KeywordRow;
		if (KeywordDataTable.FindRow(FName(idLink), KeywordRow))
		{
			if (KeywordRow.KeywordTag.MatchesTag(GameplayTags::Description_Positive))
			{
				return 0;
			}
			else if (KeywordRow.KeywordTag.MatchesTag(GameplayTags::Description_Negative))
			{
				return 1;
			}
			else if (KeywordRow.KeywordTag.MatchesTag(GameplayTags::Description_Element_Ice))
			{
				return 2;
			}
			else if (KeywordRow.KeywordTag.MatchesTag(GameplayTags::Description_Element_Fire))
			{
				return 3;
			}
		}
		return -1;
	}
}