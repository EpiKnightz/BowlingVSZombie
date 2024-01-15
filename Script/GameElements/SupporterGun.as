class ASupporterGun : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	UCapsuleComponent Collider;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent SupporterSkeleton;

	UPROPERTY(DefaultComponent, Attach = SupporterSkeleton, AttachSocket = RightGun)
	UStaticMeshComponent RightHandWp;

	UPROPERTY(BlueprintReadWrite, Category = Animation)
	UAnimMontage FiringAnim;

	UPROPERTY(BlueprintReadWrite, Category = Bullet)
	TSubclassOf<ABullet> BulletTemplate;

	UPROPERTY(BlueprintReadWrite, Category = Bullet)
	int NumberOfBullets = 3;

	int BulletsLeft = 3;

	UZombieAnimInst AnimateInst;
	UFCTweenBPActionFloat FloatTween;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AnimateInst = Cast<UZombieAnimInst>(SupporterSkeleton.GetAnimInstance());
		// Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
		BulletsLeft = NumberOfBullets;
	}

	// UFUNCTION()
	// void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	// {
	// }

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		ABowling pawn = Cast<ABowling>(OtherActor);
		if (pawn != nullptr)
		{
			Fire();
			System::SetTimer(this, n"Fire", 0.15f, true);
			AnimateInst.Montage_Play(FiringAnim);
		}
	}

	UFUNCTION()
	void Fire()
	{
		// ABullet SpawnedActor = Cast<ABullet>()
		SpawnActor(BulletTemplate, GetActorLocation(), GetActorRotation());
		BulletsLeft--;
		if (BulletsLeft <= 0)
		{
			System::ClearTimer(this, "Fire");
			BulletsLeft = NumberOfBullets;
		}
	}
}
