struct FCollectibleDT
{
	UPROPERTY()
	FString Name = "SpeedBuff";

	UPROPERTY()
	FText Description = FText::FromString("Faster");

	// UPROPERTY()
	// FVector Scale = FVector::OneVector;

	// UPROPERTY()
	// UStaticMesh PowerUpModel;

	UPROPERTY()
	UTexture PowerboxTexture;

	UPROPERTY()
	FLinearColor BoxColor;

	UPROPERTY()
	TArray<FName> EffectID;
};
