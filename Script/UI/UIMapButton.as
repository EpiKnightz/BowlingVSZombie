class UUIMapButton : UUserWidget
{
	UPROPERTY(BindWidget, BlueprintReadWrite)
	UButton ButtonBuilding;
	UPROPERTY(BindWidget)
	UImage ZombieMark;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation PopupAnim;

	UPROPERTY()
	UTexture2D Active;
	UPROPERTY()
	UTexture2D Inactive;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		ButtonBuilding.OnClicked.AddUFunction(this, n"OnClicked");
		ZombieMark.SetRenderScale(FVector2D::ZeroVector);
	}

	UFUNCTION()
	private void OnClicked()
	{
		SetActive(false);
		// Temp: TODO: Replace with UIMap.OnMapButtonClicked
		Cast<ABowlingGameMode>(Gameplay::GetGameMode()).NextLevel();
	}

	UFUNCTION()
	void SetActive(bool bActive, bool bHidden = false)
	{
		if (this.Parent.Visibility != ESlateVisibility::Collapsed)
		{
			// ButtonBuilding.SetVisibility(bActive ? ESlateVisibility::Visible : ESlateVisibility::SelfHitTestInvisible);
			ButtonBuilding.SetIsEnabled(bActive);
			this.Parent.SetVisibility(bHidden ? ESlateVisibility::Collapsed : ESlateVisibility::Visible);
		}
	}

	UFUNCTION()
	void SetZombieMark(bool bActive, UTexture2D ZombieIcon = nullptr, float AnimDelay = 0, float32 IconSize = NORMAL_ICON_SIZE)
	{
		ZombieMark.SetVisibility(bActive ? ESlateVisibility::Visible : ESlateVisibility::Hidden);
		if (bActive)
		{
			FSlateBrush Brush;
			Brush.ImageSize = FVector2f(IconSize, IconSize);
			Brush.ResourceObject = ZombieIcon;
			Brush.DrawAs = ESlateBrushDrawType::Image;
			ZombieMark.SetBrush(Brush);

			if (AnimDelay > 0)
			{
				System::SetTimer(this, n"PlayAnim", AnimDelay, false);
			}
			else
			{
				PlayAnim();
			}
		}
	}

	UFUNCTION()
	void PlayAnim()
	{
		PlayAnimation(PopupAnim);
	}

	UFUNCTION(BlueprintEvent)
	void ChangeImage(UTexture2D ActiveImage, UTexture2D InactiveImage)
	{
		// To be implemented in blueprint
	}

	UFUNCTION()
	void SetData(FMapElementDT Row)
	{
		ChangeImage(Row.Icon, Row.InactiveIcon);
	}
};