class ACompanion : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;
	default Collider.SetCollisionProfileName(n"Companion");

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent CompanionSkeleton;
	default CompanionSkeleton.SetRelativeLocation(FVector(0, 0, -50));

	UPROPERTY(DefaultComponent, Attach = CompanionSkeleton)
	UStaticMeshComponent RightHandWp;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage AttackAnim;

	UPROPERTY(BlueprintReadWrite, Category = Bullet)
	int NumberOfAtks = 3;
	int AtksLeft = 3;

	UCustomAnimInst AnimateInst;
	UFCTweenBPActionFloat FloatTween;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AnimateInst = Cast<UCustomAnimInst>(CompanionSkeleton.GetAnimInstance());
		// Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		AtksLeft = NumberOfAtks;
	}

	UFUNCTION()
	void Construct()
	{
	}

	void ResetTransform()
	{
		SetActorLocationAndRotation(FVector(0, 0, 50), FRotator::ZeroRotator);
		SetActorScale3D(FVector::OneVector);
	}

	void RegisterDragEvents(bool bEnabled = true)
	{
		ABowlingPawn Pawn = Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0));
		if (bEnabled)
		{
			Pawn.EOnTouchHold.AddUFunction(this, n"OnDragged");
			Pawn.EOnTouchReleased.AddUFunction(this, n"OnDragReleased");
		}
		else
		{
			Pawn.EOnTouchHold.UnbindObject(this);
			Pawn.EOnTouchReleased.UnbindObject(this);
		}
	}

	UFUNCTION()
	private void OnDragged(AActor OtherActor, FVector Vector)
	{
		SetActorLocation(FVector(Vector.X, Vector.Y, GetActorLocation().Z));
	}

	UFUNCTION()
	private void OnDragReleased(AActor OtherActor, FVector Vector)
	{
		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, 50));
		RegisterDragEvents(false);
	}
}
