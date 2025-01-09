const int MAX_STATUS_ICON = 3;

class UUIStatusBar : UUserWidget
{
	UPROPERTY(BindWidget)
	UHorizontalBox StatusHorBox;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Appearance")
	UTexture2D EtcIcon;

	UPROPERTY()
	TSubclassOf<UUIStatusIcon> StatusIconClass;

	UFUNCTION()
	void AddStatus(UStatusComponent StatComp, UTexture2D Icon)
	{
		UUIStatusIcon NewStatusIcon = Cast<UUIStatusIcon>(WidgetBlueprint::CreateWidget(StatusIconClass, GetOwningPlayer()));
		StatComp.EOnDurationChanged.AddUFunction(NewStatusIcon, n"OnDurationChanged");
		StatComp.EOnStackChanged.AddUFunction(NewStatusIcon, n"OnStackChanged");
		StatComp.EOnEndStatusEffect.AddUFunction(NewStatusIcon, n"OnEndStatusEffect");
		StatComp.EOnEndStatusEffect.AddUFunction(this, n"RemoveStatus");
		NewStatusIcon.Init(Icon);
		StatusHorBox.AddChildToHorizontalBox(NewStatusIcon);
		if (StatusHorBox.GetChildrenCount() > MAX_STATUS_ICON)
		{
			NewStatusIcon.SetVisibility(ESlateVisibility::Hidden);
			Cast<UUIStatusIcon>(StatusHorBox.GetChildAt(MAX_STATUS_ICON - 1)).SetEtc(EtcIcon);
		}
	}

	UFUNCTION()
	void RemoveStatus()
	{
		if (StatusHorBox.GetChildrenCount() == MAX_STATUS_ICON)
		{
			Cast<UUIStatusIcon>(StatusHorBox.GetChildAt(MAX_STATUS_ICON - 1)).SetEtc(nullptr, false);
		}
	}
}