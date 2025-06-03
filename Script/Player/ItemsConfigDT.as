struct FItemPoolConfigDT
{
	// UPROPERTY()
	// TArray<FName> ItemIDs;

	UPROPERTY()
	TArray<FGameplayTag> ItemTags;

	int Num()
	{
		return ItemTags.Num();
	}

	FGameplayTag GetTag(int Index)
	{
		return ItemTags[Index];
	}

	FGameplayTag GetRandomTag()
	{
		if (ItemTags.Num() == 0)
		{
			return FGameplayTag();
		}
		int Idx = ItemTags.Num() > 1 ? Math::RandRange(0, ItemTags.Num() - 1) : 0;
		return ItemTags[Idx];
	}

	void AddUniqueTag(FGameplayTag ItemTag)
	{
		if (ItemTag.IsValid())
		{
			ItemTags.AddUnique(ItemTag);
		}
	}

	void Remove(FGameplayTag ItemTag)
	{
		if (ItemTag.IsValid())
		{
			ItemTags.Remove(ItemTag);
		}
	}

	bool IsEmpty()
	{
		return ItemTags.Num() == 0;
	}
}