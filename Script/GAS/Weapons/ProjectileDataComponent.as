class UProjectileDataComponent : UActorComponent
{
	UPROPERTY(BlueprintReadOnly, Category = "Stats")
	FProjectileSpec ProjectileData;

	void SetAttack(float32 iAtk)
	{
		ProjectileData.Atk = iAtk;
	}
};