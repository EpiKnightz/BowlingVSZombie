class UProjectileDataComponent : UActorComponent
{
	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	FProjectileSpec ProjectileData;

	void SetAttack(float32 iAtk)
	{
		ProjectileData.Atk = iAtk;
	}

	void AddEffects(FGameplayTagContainer NewEffects)
	{
		if (NewEffects.Num() > 0)
		{
			ProjectileData.EffectTags.AppendTags(NewEffects);
		}
	}
};