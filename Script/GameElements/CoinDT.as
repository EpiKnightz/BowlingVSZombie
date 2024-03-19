struct FCoinDT
{
	UPROPERTY()
	ECoinType CoinType = ECoinType::Bronze;

	UPROPERTY()
	UStaticMesh CoinMesh;

	UPROPERTY()
	int CoinValue;
};