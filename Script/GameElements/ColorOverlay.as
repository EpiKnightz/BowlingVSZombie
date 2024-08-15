class UColorOverlay
{
	UMaterialInstanceDynamic DynamicMat;
	private FLinearColor CachedOverlayColor = FLinearColor::Transparent;

	UFUNCTION()
	void SetupDynamicMaterial(UMaterialInterface Material)
	{
		DynamicMat = Material::CreateDynamicMaterialInstance(Material);
	}

	UFUNCTION()
	void ResetOverlayColor()
	{
		ChangeOverlayColor(FLinearColor::Transparent, true);
	}

	UFUNCTION()
	void RevertOverlayColor()
	{
		ChangeOverlayColor(CachedOverlayColor);
	}

	UFUNCTION()
	void ChangeOverlayColor(FLinearColor Color, bool bCached = false)
	{
		DynamicMat.SetVectorParameterValue(n"OverlayColor", Color);
		if (bCached)
		{
			CachedOverlayColor = Color;
		}
	}
};