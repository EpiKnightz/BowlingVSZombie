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

	UPROPERTY()
	TSubclassOf<ACompanion> CompanionClass;

	private ACompanion SpawnedCompanion;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		Pawn.EOnTouchTriggered.AddUFunction(this, n"OnTouchTriggered");

		TemplSequActor = NewObject(this, ATemplateSequenceActor);

		SpawnedCompanion = Cast<ACompanion>(SpawnActor(CompanionClass, CompanionTransform.Location, CompanionTransform.Rotation.Rotator()));
		// TODO move this into a component to avoid casting
		SpawnedCompanion.AttachToActor(this, NAME_None, EAttachmentRule::KeepRelative);
		SpawnedCompanion.SetActorRelativeScale3D(CompanionTransform.Scale3D);
	}

	UFUNCTION()
	void Init(int iID)
	{
		ID = iID;
		UTemplateSequencePlayer::CreateTemplateSequencePlayer(IntroSequences[ID], FMovieSceneSequencePlaybackSettings(), TemplSequActor);
		TemplSequActor.SetBinding(this);
		TemplSequActor.GetSequencePlayer().Play();
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