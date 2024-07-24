class APowerManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable PowerDataTable;

	TArray<FPowerDT> PowersDataArray;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		PowerDataTable.GetAllRows(PowersDataArray);
	}

	UFUNCTION()
	FPowerDT GetPowerData(FName PowerID)
	{
		FPowerDT Power;
		if (PowerDataTable.FindRow(PowerID, Power) != false)
		{
			return Power;
		}
		else
		{
			PrintError("GetSurvivorData: PowerID not found");
			return Power;
		}
	}

	UFUNCTION()
	UModifier CreatePowerModifier(FPowerDT PowerData)
	{
		UModifier Mod = Cast<UModifier>(NewObject(this, PowerData.Modifier.DefaultObject.Class));
		Mod.AddParams(PowerData.Params);
		return Mod;
	}
};