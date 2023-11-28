class AZombie : AActor
{
    UPROPERTY(BlueprintReadWrite)
    float MoveSpeed = 100;
    UPROPERTY(BlueprintReadWrite)
    int HP = 200;

    UPROPERTY(RootComponent, DefaultComponent)
    UCapsuleComponent Collider;

    UPROPERTY(DefaultComponent)
    USkeletalMeshComponent ZombieSkeleton;

    UPROPERTY(DefaultComponent, Attach = ZombieSkeleton, AttachSocket = RightHand)
    UStaticMeshComponent RightHandWp;

    UPROPERTY(DefaultComponent, Attach = ZombieSkeleton, AttachSocket = LeftHand)
    UStaticMeshComponent LeftHandWp;

    UPROPERTY(BlueprintReadWrite)
    TArray<UStaticMesh> WeaponList;

    UPROPERTY(BlueprintReadWrite, Category = Animation)
    UAnimMontage EmergeAnim;

    UPROPERTY(BlueprintReadWrite, Category = Animation)
    UAnimMontage DamageAnim;

    UPROPERTY(BlueprintReadWrite, Category = Animation)
    UAnimMontage AttackAnim;

    UPROPERTY(BlueprintReadWrite, Category = Animation)
    TArray<UAnimMontage> DeadAnims;

    UPROPERTY(BlueprintReadWrite, Category = Animation)
    TArray<UAnimationAsset> DeadLoopAnims;

    float delayMove = 3;
    int currentDeadAnim = 0;
    bool bIsDead = false;
    bool bIsAttacking = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        if (Math::RandBool() == true)
        {
            RightHandWp.StaticMesh = WeaponList[Math::RandRange(0, WeaponList.Num()-1)];
        }else
        {
            RightHandWp.StaticMesh = nullptr;
        }
        if (Math::RandBool() == true)
        {
            LeftHandWp.StaticMesh = WeaponList[Math::RandRange(0, WeaponList.Num()-1)];
        }else
        {
            LeftHandWp.StaticMesh = nullptr;
        }
        Collider.OnComponentHit.AddUFunction(this, n"ActorBeginHit");
        ZombieSkeleton.GetAnimInstance().Montage_Play(EmergeAnim);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        delayMove -= DeltaSeconds;
        if (delayMove<=0)
        {
            FVector loc = GetActorLocation();
            if (bIsDead)
            {
                loc.Z -= MoveSpeed * DeltaSeconds;
            }else if (loc.X < 900)
            {
                loc.X += MoveSpeed * DeltaSeconds;
                if (loc.X > 900) loc.X = 900;
            }else if (loc.X == 900 && bIsAttacking == false)
            {
                bIsAttacking = true;
                Attacking(nullptr,false);
            }
            SetActorLocation(loc);
            if (loc.Z <= -10)
            {
                DestroyActor();
            }
        }
    }

    void SetSkeletonMesh(USkeletalMesh mesh)
    {
        ZombieSkeleton.SkeletalMeshAsset = mesh;
    }

    UFUNCTION()
    void ActorBeginHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
    {
        Print("Hello");
        if (HP > 0)
        {
            ABowling pawn = Cast<ABowling>(OtherActor);
            if (pawn != nullptr)
            {
                HP -= 50;
                Print("Hit:" + HP);

                if (HP <= 0)
                {
                    Collider.SetCollisionEnabled(ECollisionEnabled::NoCollision);
                    ZombieSkeleton.GetAnimInstance().StopSlotAnimation();
                    currentDeadAnim = Math::RandRange(0,DeadAnims.Num() - 1);
                    ZombieSkeleton.GetAnimInstance().Montage_Play(DeadAnims[currentDeadAnim]);
                    ZombieSkeleton.GetAnimInstance().OnMontageBlendingOut.AddUFunction(this, n"Dead");
                    delayMove = 2.2f;
                    bIsDead = true;
                }else
                {
                    ZombieSkeleton.GetAnimInstance().Montage_Play(DamageAnim);
                    if (bIsAttacking)
                    {
                        ZombieSkeleton.GetAnimInstance().OnMontageBlendingOut.AddUFunction(this, n"Attacking");
                    }
                    delayMove = 1;
                }
            }
        }
    }

    UFUNCTION()
    void Dead(UAnimMontage Montage, bool bInterrupted)
    {
        ZombieSkeleton.PlayAnimation(DeadLoopAnims[currentDeadAnim], true);
    }

    UFUNCTION()
    void Attacking(UAnimMontage Montage, bool bInterrupted)
    {
        ZombieSkeleton.GetAnimInstance().StopSlotAnimation();
        ZombieSkeleton.PlayAnimation(AttackAnim, true);
    }
}
