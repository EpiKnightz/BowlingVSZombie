class UProjectileDataComponent : UActorComponent
{
	private FProjectileSpec ProjectileData;

	FProjectileSpec GetProjectileData()
	{
		return ProjectileData;
	}

	void SetWeaponData(FWeaponDT WeaponData)
	{
		ProjectileData = WeaponData;
	}

	void SetBallData(FBallDT BallData)
	{
		ProjectileData = BallData;
	}

	void SetAbilityData(FAbilityDT AbilityData)
	{
		ProjectileData = AbilityData;
	}

	void SetAttack(float32 iAtk)
	{
		ProjectileData.Atk = iAtk;
	}

	float32 GetAttack()
	{
		return ProjectileData.Atk;
	}

	void AddEffects(FGameplayTagContainer NewEffects)
	{
		if (NewEffects.Num() > 0)
		{
			ProjectileData.EffectTags.AppendTags(NewEffects);
		}
	}

	FGameplayTagContainer GetEffects()
	{
		return ProjectileData.EffectTags;
	}
};