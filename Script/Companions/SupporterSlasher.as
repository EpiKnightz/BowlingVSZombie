class ASupporterSlasher : ACompanion
{
	UPROPERTY(BlueprintReadWrite)
	float RotateTimer = 1;

	float CurrentTimer = 0;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		RightHandWp.AttachTo(CompanionSkeleton, n"RightHand");
	}

	UFUNCTION(BlueprintOverride)
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
				TArray<AActor> ignoreActors;
				TArray<AActor> outActors;
				System::SphereOverlapActors(GetActorLocation(), 165, traceObjectTypes, nullptr, ignoreActors, outActors);

				for (AActor overlappedActor : outActors)
				{
					UDamageResponseComponent damageResponse = UDamageResponseComponent::Get(overlappedActor);
					if (IsValid(damageResponse))
					{
						damageResponse.DOnTakeHit.ExecuteIfBound(100);
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
