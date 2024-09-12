class UColorOverlay
{
	UMaterialInstanceDynamic DynamicMat;
	private FLinearColor CachedOverlayColor = FLinearColor::Transparent;

	UFUNCTION()
	void SetupDynamicMaterial(UMaterialInterface Material)
	{
		DynamicMat = Material::CreateDynamicMaterialInstance(Material);
	}

	FLinearColor GetCachedOverlayColor()
	{
		return CachedOverlayColor;
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
		if (bCached)
		{
			if (CachedOverlayColor != Color)
			{
				CachedOverlayColor = Color;
				DynamicMat.SetVectorParameterValue(n"OverlayColor", Color);
			}
		}
		else
		{
			DynamicMat.SetVectorParameterValue(n"OverlayColor", Color);
		}
	}
};