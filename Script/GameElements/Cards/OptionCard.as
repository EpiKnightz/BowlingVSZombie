class AOptionCard : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent Collider;

	UPROPERTY(DefaultComponent, Attach = Collider)
	UStaticMeshComponent CardMesh;
	default CardMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);

	UPROPERTY(DefaultComponent, Attach = CardMesh)
	UWidgetComponent TextWidget;
	default TextWidget.SetCollisionEnabled(ECollisionEnabled::NoCollision);
	default TextWidget.ReceivesDecals = false;

	UPROPERTY()
	TArray<UTemplateSequence> IntroSequences;

	FIntDelegate DOnCardClicked;

	private ATemplateSequenceActor TemplSequActor;
	private int ID;

	UPROPERTY()
	FTransform CompanionTransform;

	// UPROPERTY()
	// TSubclassOf<ASurvivor> CompanionClass;

	private ASurvivor SpawnedCompanion;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.EOnTouchTriggered.AddUFunction(this, n"OnTouchTriggered");

		TemplSequActor = NewObject(this, ATemplateSequenceActor);
	}

	UFUNCTION()
	void Init(int iID)
	{
		// CompanionClass = iCompanionClass;
		ID = iID;

		ASurvivorManager SM = Gameplay::GetActorOfClass(ASurvivorManager);
		if (SM.CreateRandomSurvior(SpawnedCompanion))
		{
			SpawnedCompanion.SetActorLocationAndRotation(CompanionTransform.Location, CompanionTransform.Rotation.Rotator());
			// TODO move this into a component to avoid casting
			SpawnedCompanion.AttachToActor(this, NAME_None, EAttachmentRule::KeepRelative);
			SpawnedCompanion.SetTempScale(CompanionTransform.Scale3D);

			UTemplateSequencePlayer::CreateTemplateSequencePlayer(IntroSequences[ID], FMovieSceneSequencePlaybackSettings(), TemplSequActor);
			TemplSequActor.SetBinding(this);
			TemplSequActor.GetSequencePlayer().SetPlayRate(1 / Gameplay::GetGlobalTimeDilation());
			TemplSequActor.GetSequencePlayer().Play();
		}
	}

	UFUNCTION()
	void OnTouchTriggered(AActor OtherActor, FVector Location)
	{
		if (OtherActor == this)
		{
			DOnCardClicked.ExecuteIfBound(ID);
			SpawnedCompanion.DetachFromActor();
			SpawnedCompanion.ResetTransform();
			SpawnedCompanion.RegisterDragEvents();
			SpawnedCompanion = nullptr;
			OnFinished();
		}
	}

	UFUNCTION()
	void Outro()
	{
		Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		TemplSequActor.GetSequencePlayer().PlayReverse();
		TemplSequActor.GetSequencePlayer().OnFinished.AddUFunction(this, n"OnFinished");
	}

	UFUNCTION()
	private void OnFinished()
	{
		if (IsValid(SpawnedCompanion))
		{
			SpawnedCompanion.DestroyActor();
		}
		DestroyActor();
	}
};