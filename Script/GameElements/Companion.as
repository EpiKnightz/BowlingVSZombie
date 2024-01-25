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

	// UFUNCTION()
	// void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	// {
	// }
}
