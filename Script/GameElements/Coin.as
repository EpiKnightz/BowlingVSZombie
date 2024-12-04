enum ECoinType
{
	Null = -1,
	Bronze = 0,
	Silver = 1,
	Gold = 2,
	Epic = 3,
	Mythic = 4,
	Multi = 5,
}

const float BRONZE_COIN_VALUE = 1;
const float SILVER_COIN_VALUE = 3;
const float GOLD_COIN_VALUE = 12;
const float EPIC_COIN_VALUE = 60;
const float MYTHIC_COIN_VALUE = 300;

class ACoin : ACollectible
{
	default DropComponent.StartHeight = 150;
	default DropComponent.DropDuration = 2;

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
		ACollectible::BeginPlay();
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
		// Stupid code I know but it works
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
		else if (Value <= GOLD_COIN_VALUE)
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
		else if (Value <= EPIC_COIN_VALUE)
		{
			if (Math::RandRange(0.0, 1.0) > ((EPIC_COIN_VALUE - Value) / (EPIC_COIN_VALUE - GOLD_COIN_VALUE)))
			{
				SetCoinType(ECoinType::Epic);
			}
			else
			{
				SetCoinType(ECoinType::Gold);
			}
		}
		else if (Value <= MYTHIC_COIN_VALUE)
		{
			if (Math::RandRange(0.0, 1.0) > ((MYTHIC_COIN_VALUE - Value) / (MYTHIC_COIN_VALUE - EPIC_COIN_VALUE)))
			{
				SetCoinType(ECoinType::Mythic);
			}
			else
			{
				SetCoinType(ECoinType::Epic);
			}
		}
	}

	void OnCollectibleOverlap(AActor OtherActor) override
	{
		ACollectible::OnCollectibleOverlap(OtherActor);
		DOnCoinCombo.ExecuteIfBound(CoinData.CoinValue);
	}

	void OnCollectibleCollected(AActor OtherActor) override
	{
		DOnCoinGet.ExecuteIfBound(CoinData.CoinValue);
	}
};