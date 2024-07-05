
// This is for data storage only, it shouldn't be a data table
struct FProjectileData
{
	UPROPERTY()
	float32 Atk = 50;

	UPROPERTY()
	bool bIsPiercable = false;

	UPROPERTY(meta = (Categories = "Status"))
	FGameplayTagContainer EffectTags;

	FProjectileData& opAssign(FBallDT Other)
	{
		Atk = Other.Atk;
		bIsPiercable = Other.bIsPiercable;
		EffectTags = Other.EffectTags;
		return this;
	}

	FProjectileData& opAssign(FSurvivorDT Other)
	{
		Atk = Other.Atk;
		if (Other.EffectTags.HasTagExact(GameplayTags::Ability_Effect_Piercing))
		{
			bIsPiercable = true;
		}
		EffectTags = Other.EffectTags.Filter(
			GameplayTag::MakeGameplayTagContainerFromTag(GameplayTags::Status_Negative));
		return this;
	}
}