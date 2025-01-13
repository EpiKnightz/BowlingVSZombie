class UUIGuideArrow : UUserWidget
{
	UPROPERTY(NotEditable, Transient, meta = (BindWidgetAnim))
	UWidgetAnimation ArrowAnim;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		PlayAnimation(ArrowAnim);
	}
}