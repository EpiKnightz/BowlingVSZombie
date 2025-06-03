class USaveRun : USaveGame
{
	UPROPERTY(VisibleAnywhere, Category = Basic)
	FRunData RunData;

	UPROPERTY(VisibleAnywhere, Category = Map)
	int MapSeed;
};