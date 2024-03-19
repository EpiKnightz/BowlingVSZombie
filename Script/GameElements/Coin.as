enum ECoinType
{
	Bronze = 0,
	Silver = 1,
	Gold = 2
}

const float BRONZE_COIN_VALUE = 1;
const float SILVER_COIN_VALUE = 5;
const float GOLD_COIN_VALUE = 10;

delegate void FCoinGetDelegate(int Value);

class ACoin : AActor
{
	UPROPERTY(RootComponent, DefaultComponent)
	USphereComponent Collider;

	UPROPERTY(DefaultComponent)
	UStaticMeshComponent CoinMesh;
	default CoinMesh.CollisionEnabled = ECollisionEnabled::NoCollision;

	UPROPERTY(DefaultComponent, Attach = CoinMesh)
	UNiagaraComponent TrailVFX;
	default TrailVFX.bAutoActivate = false;

	UPROPERTY(DefaultComponent)
	URotatingMovementComponent RotateMovement;
	default RotateMovement.bUpdateOnlyIfRendered = true;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent HomingMovement;
	default HomingMovement.bRotationFollowsVelocity = false;
	default HomingMovement.bIsHomingProjectile = true;
	default HomingMovement.InitialSpeed = 0;
	default HomingMovement.MaxSpeed = 3000;
	default HomingMovement.HomingAccelerationMagnitude = 2000;
	default HomingMovement.ProjectileGravityScale = 0;
	default HomingMovement.bConstrainToPlane = true;
	default HomingMovement.PlaneConstraintAxisSetting = EPlaneConstraintAxisSetting::Z;

	ECoinType CoinType;

	UPROPERTY(BlueprintReadWrite)
	UDataTable CoinDT;

	UPROPERTY()
	FCoinDT CoinData;

	FCoinGetDelegate CoinGetDelegate;
	FCoinGetDelegate CoinComboDelegate;

	UPROPERTY()
	float ReverseSpeed = 1000;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ABowlingGameMode GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
		CoinGetDelegate.BindUFunction(GM, n"CoinGetHandler");
		CoinComboDelegate.BindUFunction(Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0)), n"CoinComboHandler");
		TrailVFX.SetActive(false);
		// SetTarget(Gameplay::GetPlayerPawn(0).RootComponent);
	}

	UFUNCTION()
	void SetCoinType(ECoinType NewCoinType)
	{
		CoinType = NewCoinType;
		CoinDT.FindRow(FName("Item_" + int(CoinType)), CoinData);
		CoinMesh.SetStaticMesh(CoinData.CoinMesh);
	}

	UFUNCTION()
	void ExpectValueToCoinType(float Value)
	{
		if (Value <= SILVER_COIN_VALUE)
		{
			if (Math::RandRange(0.0, 1.0) > ((SILVER_COIN_VALUE - Value) / (SILVER_COIN_VALUE - BRONZE_COIN_VALUE)))
			{
				SetCoinType(ECoinType::Silver);
			}
			else
			{
				SetCoinType(ECoinType::Bronze);
			}
		}
		else
		{
			if (Math::RandRange(0.0, 1.0) > ((GOLD_COIN_VALUE - Value) / (GOLD_COIN_VALUE - SILVER_COIN_VALUE)))
			{
				SetCoinType(ECoinType::Gold);
			}
			else
			{
				SetCoinType(ECoinType::Silver);
			}
		}
	}

	UFUNCTION()
	void SetTarget(USceneComponent NewTarget)
	{
		HomingMovement.SetHomingTargetComponent(NewTarget);
		HomingMovement.Velocity = (GetActorLocation() - Gameplay::GetPlayerPawn(0).GetActorLocation()).GetSafeNormal() * ReverseSpeed;
		TrailVFX.Activate();
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		if (OtherActor.IsA(ABowling) && HomingMovement.GetHomingTargetComponent() == nullptr)
		{
			SetTarget(OtherActor.GetOwner().RootComponent);
		}
		if (OtherActor.IsA(ABowlingPawn))
		{
			CoinGetDelegate.ExecuteIfBound(CoinData.CoinValue);
			DestroyActor();
		}
	}
};