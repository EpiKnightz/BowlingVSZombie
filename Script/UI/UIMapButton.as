class UUIMapButton : UUserWidget
{
	UPROPERTY(BindWidget, BlueprintReadWrite)
	UButton ButtonBuilding;
	UPROPERTY(BindWidget)
	UImage ZombieMark;
	UPROPERTY(BindWidget)
	UImage ClearMark;

	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation PopupAnim;
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ClearAnim;

	UPROPERTY()
	UTexture2D Active;
	UPROPERTY()
	UTexture2D Inactive;

	private int CurrentMapPosition = -1;
	private EMapElement CurrentMapElementType = EMapElement::None;
	FVoidDelegate OnLockClicked;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		ZombieMark.SetRenderScale(FVector2D::ZeroVector);
	}

	UFUNCTION()
	private void OnClicked()
	{
		// SetActive(false);
		//  Temp: TODO: Replace with UIMap.OnMapButtonClicked
		auto GameInst = Cast<UBowlingGameInstance>(GameInstance);
		if (IsValid(GameInst))
		{
			GameInst.NextLevel(CurrentMapPosition);
		}
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

	void SetLock(bool bLocked = false)
	{

		if (bLocked)
		{
			if (OnLockClicked.IsBound())
			{
				ButtonBuilding.OnClicked.AddUFunction(OnLockClicked.UObject, OnLockClicked.FunctionName);
			}
			else
			{
				ButtonBuilding.SetVisibility(bLocked ? ESlateVisibility::HitTestInvisible : ESlateVisibility::Visible);
			}
		}
		else
		{
			ButtonBuilding.OnClicked.AddUFunction(this, n"OnClicked");
		}
	}

	UFUNCTION()
	void SetClear(bool bCleared = false, bool bPlayAnim = true)
	{
		if (ZombieMark.IsVisible())
		{
			ClearMark.SetVisibility(bCleared ? ESlateVisibility::Visible : ESlateVisibility::Hidden);
			if (bCleared && bPlayAnim)
			{
				PlayAnimation(ClearAnim);
			}
		}
		else if (CurrentMapElementType != EMapElement::Store)
		{
			SetActive(false, false);
		}
	}

	UFUNCTION(BlueprintOverride)
	void OnAnimationFinished(const UWidgetAnimation Animation)
	{
		if (Animation == ClearAnim && CurrentMapElementType != EMapElement::Store)
		{
			SetActive(false, false);
		}
	}

	UFUNCTION()
	void SetZombieMark(bool bActive, UTexture2D ZombieIcon = nullptr, float AnimDelay = 0, float32 IconSize = NORMAL_ICON_SIZE)
	{
		ZombieMark.SetVisibility(bActive ? ESlateVisibility::HitTestInvisible : ESlateVisibility::Hidden);
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
	void SetData(FMapElementDT Row, int MapPosition)
	{
		CurrentMapPosition = MapPosition;
		CurrentMapElementType = Row.Type;
		ChangeImage(Row.Icon, Row.InactiveIcon);
	}
};