class ABowlingPlayerController : APlayerController
{
	UPROPERTY(BlueprintReadOnly, Category = Input)
	UInputMappingContext InputMappingContext;

	default bShowMouseCursor = true;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// get the enhanced input subsystem
		auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(GetLocalPlayer());
		check(Subsystem != nullptr);
		if (Subsystem != nullptr)
		{
			// add the mapping context so we get controls
			Subsystem.AddMappingContext(InputMappingContext, 0, FModifyContextOptions());
		}
	}

	UFUNCTION()
	void ClearMappingContext()
	{
		auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(GetLocalPlayer());
		check(Subsystem != nullptr);
		if (Subsystem != nullptr)
		{
			Subsystem.RemoveMappingContext(InputMappingContext, FModifyContextOptions());
		}
	}
}
