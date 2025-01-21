
namespace ProjectileSpec
{
	const float32 UNINIT_VALUE = -99999;
}
// This is for data storage only, it shouldn't be a data table
struct FProjectileSpec
{
	UPROPERTY()
	float32 Atk = ProjectileSpec::UNINIT_VALUE;

	UPROPERTY()
	bool bIsPiercable = false;

	UPROPERTY(meta = (Categories = "Status"))
	FGameplayTagContainer EffectTags;

	FProjectileSpec& opAssign(FBallDT Other)
	{
		Atk = Other.Atk;
		bIsPiercable = Other.bIsPiercable;
		EffectTags = Other.EffectTags;
		return this;
	}

	// FProjectileSpec& opAssign(FSurvivorDT Other)
	// {
	// 	Atk = Other.Atk;
	// 	if (Other.EffectTags.HasTagExact(GameplayTags::Ability_Effect_Piercing))
	// 	{
	// 		bIsPiercable = true;
	// 	}
	// 	EffectTags = Other.EffectTags.Filter(
	// 		GameplayTags::Status_Negative.GetSingleTagContainer());
	// 	return this;
	// }

	FProjectileSpec& opAssign(FWeaponDT Other)
	{
		Atk = Other.Attack;
		if (Other.EffectTags.HasTagExact(GameplayTags::Effect_Piercing))
		{
			bIsPiercable = true;
		}
		EffectTags = Other.EffectTags.Filter(
			GameplayTags::Status_Negative.GetSingleTagContainer());
		return this;
	}

	FProjectileSpec& opAssign(FAbilityDT Other)
	{
		if (Other.AbilityTags.HasTagExact(GameplayTags::Effect_Piercing))
		{
			bIsPiercable = true;
		}
		EffectTags = Other.AbilityTags.Filter(
			GameplayTags::Status_Negative.GetSingleTagContainer());
		return this;
	}
}