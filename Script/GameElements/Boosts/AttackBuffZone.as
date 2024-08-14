class AAttackBuffZone : AZone
{
	UPROPERTY(DefaultComponent)
	UNiagaraComponent VFXComponent;

	private int ModID = 1;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0)).DOnChangeGuideArrowTarget.ExecuteIfBound(GetActorLocation());
		System::SetTimer(this, n"K2_DestroyActor", 10, false);
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
			Pawn.DOnHideArrow.ExecuteIfBound();
			// TODO: Move guide arrow into a component.
		}
		System::ClearTimer(this, "K2_DestroyActor");
		DestroyActor();
	}
};