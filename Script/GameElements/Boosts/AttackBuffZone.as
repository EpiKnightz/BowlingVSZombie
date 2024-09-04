class AAttackBuffZone : AZone
{
	UPROPERTY(DefaultComponent)
	UNiagaraComponent VFXComponent;

	FVoidDelegate DHideGuideArrow;

	private int ModID = 1;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		if (IsValid(Pawn))
		{
			Pawn.DOnChangeGuideArrowTarget.ExecuteIfBound(GetActorLocation());
			DHideGuideArrow.BindUFunction(Pawn, n"HideGuideArrow");
		}
		System::SetTimer(this, n"Destroy", 10, false);
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
		if (IsValid(StatusResponse))
		{
			StatusResponse.DOnApplyStatus.ExecuteIfBound(GameplayTags::Status_Positive_AttackBoost.GetSingleTagContainer());
		}

		auto Pawn = Cast<ABowlingPawn>(OtherActor);
		if (IsValid(Pawn))
		{
			// Pawn.DOnHideArrow.ExecuteIfBound();
			//  TODO: Move guide arrow into a component.
			System::ClearTimer(this, "Destroy");
			Destroy();
		}
	}

	UFUNCTION()
	void Destroy()
	{
		DHideGuideArrow.ExecuteIfBound();
		DestroyActor();
	}
};