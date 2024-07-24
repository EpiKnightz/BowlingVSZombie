class ABoost : ACollectable
{
	UPROPERTY(DefaultComponent)
	UNiagaraComponent PowerBox;

	UPROPERTY(Category = "Attributes")
	UMaterialInterface PowerboxMaterial;

	// UPROPERTY(Category = "Attributes")
	// FLinearColor GlowColor;

	UMaterialInstanceDynamic DynamicMat;

	FCollectibleDT PowerUpData;
	FStatusDT StatusData;

	UFUNCTION(BlueprintOverride, BlueprintCallable)
	void ConstructionScript()
	{
		DynamicMat = Material::CreateDynamicMaterialInstance(PowerboxMaterial);
		PowerBox.SetVariableMaterial(n"BoxMaterial", DynamicMat);
	}

	UFUNCTION(BlueprintCallable)
	void UpdateBoxData()
	{
		PowerBox.SetVariableLinearColor(n"BoxColor", PowerUpData.BoxColor);
		// PowerBox.SetVariableLinearColor(n"GlowColor", GlowColor);
		DynamicMat.SetTextureParameterValue(n"Powerbox_Icon_Texture", PowerUpData.PowerboxTexture);
	}

	UFUNCTION()
	void InitData(FCollectibleDT iPUData, FStatusDT iData)
	{
		PowerUpData = iPUData;
		StatusData = iData;
		UpdateBoxData();
	}

	// UFUNCTION(BlueprintOverride)
	// void ActorBeginOverlap(AActor OtherActor)
	// {
	// 	Super::ActorBeginOverlap(OtherActor);
	// 	// PowerBox.SetEmitterEnable(n"GlowCircle", true);
	// }

	void OnCollectibleCollected(AActor OtherActor) override
	{
		// Need to use the data here.
		auto StatusResponse = UStatusResponseComponent::Get(OtherActor);
		if (IsValid(StatusResponse))
		{
			StatusResponse.DOnApplyStatus.ExecuteIfBound(GameplayTag::MakeGameplayTagContainerFromTag(GameplayTags::Status_Positive_CooldownBoost));
		}
	}
};