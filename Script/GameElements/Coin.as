enum ECoinType
{
	Bronze = 0,
	Silver = 1,
	Gold = 2
}

const float BRONZE_COIN_VALUE = 1;
const float SILVER_COIN_VALUE = 5;
const float GOLD_COIN_VALUE = 10;

class ACoin : ACollectible
{
	ECoinType CoinType;

	UPROPERTY(BlueprintReadWrite)
	UDataTable CoinDT;

	UPROPERTY()
	FCoinDT CoinData;

	FIntDelegate DOnCoinGet;
	FIntDelegate DOnCoinCombo;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		ABowlingGameMode GM = Cast<ABowlingGameMode>(Gameplay::GetGameMode());
		DOnCoinGet.BindUFunction(GM, n"CoinGetHandler");
		DOnCoinCombo.BindUFunction(Cast<ABowlingPawn>(Gameplay::GetPlayerPawn(0)), n"CoinComboHandler");
	}

	UFUNCTION()
	void SetCoinType(ECoinType NewCoinType)
	{
		CoinType = NewCoinType;
		CoinDT.FindRow(FName("Item_" + int(CoinType)), CoinData);
		Mesh.SetStaticMesh(CoinData.CoinMesh);
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

	void OnCollectibleOverlap(AActor OtherActor) override
	{
		DOnCoinCombo.ExecuteIfBound(CoinData.CoinValue);
	}

	void OnCollectibleCollected(AActor OtherActor) override
	{
		DOnCoinGet.ExecuteIfBound(CoinData.CoinValue);
	}
};