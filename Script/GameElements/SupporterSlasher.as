class ASupporterSlasher : ACompanion
{
#if EDITOR
	default RightHandWp.AttachTo(CompanionSkeleton, n"RightHand");
#endif

	UPROPERTY(BlueprintReadWrite)
	float RotateTimer = 1;

	float CurrentTimer = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RightHandWp.AttachTo(CompanionSkeleton, n"RightHand");
		Super::BeginPlay();
	}

	UFUNCTION(BlueprintOverride, Meta = (NoSuperCall))
	void ActorBeginOverlap(AActor OtherActor)
	{
		ABowling pawn = Cast<ABowling>(OtherActor);
		if (pawn != nullptr)
		{
			if (CurrentTimer <= 0)
			{
				AnimateInst.Montage_Play(AttackAnim);
				System::SetTimer(this, n"SetRotate", 0.15f, false);

				TArray<EObjectTypeQuery> traceObjectTypes;
				traceObjectTypes.Add(EObjectTypeQuery::Enemy);

				// traceObjectTypes.Add(UEngineTypes::StaticClass().ConvertToObjectType)
				// traceObjectTypes.Add(UEngineTypes::ConvertToObjectType(ECollisionChannel::ECC_GameTraceChannel3));
				// // UClass* seekClass = nullptr;
				TArray<AActor> ignoreActors;
				TArray<AActor> outActors;
				System::SphereOverlapActors(GetActorLocation(), 165, traceObjectTypes, nullptr, ignoreActors, outActors);

				for (AActor overlappedActor : outActors)
				{
					AZombie zomb = Cast<AZombie>(overlappedActor);
					if (zomb != nullptr)
					{
						zomb.TakeHit(50);
					}
				}
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (CurrentTimer > 0)
		{
			CurrentTimer -= DeltaSeconds;

			SetActorRotation(FRotator(0, Math::Lerp(55, -305, CurrentTimer / RotateTimer), 0));
		}
	}

	UFUNCTION()
	void SetRotate()
	{
		CurrentTimer = RotateTimer;
	}
}
