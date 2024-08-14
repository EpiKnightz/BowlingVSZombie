enum ECardType
{
	None,
	Power,
	Survivor,
	Ability,
	Weapon
} struct FCardDT
{
	UPROPERTY()
	FString Name = "Bouncer Power";

	UPROPERTY()
	FText Description = FText::FromString("After 1st bounce, Increase bowling's damage by 1.5x");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY()
	FGameplayTag ItemID;

	ECardType CardType = ECardType::None;

	bool IsValid()
	{
		return CardType != ECardType::None;
	}

	void SetID(FGameplayTag ID)
	{
		ItemID = ID;
	}

	FCardDT(FGameplayTag Tag, ECardType iCardType)
	{
		ItemID = Tag;
		CardType = iCardType;
	}

	FCardDT(FSurvivorDT Other)
	{
		if (Other.SurvivorID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Survivor;
			ItemID = Other.SurvivorID;
		}
	}

	FCardDT& opAssign(FPowerDT Other)
	{
		Name = Other.Name;
		Description = Other.Description;
		Icon = Other.Icon;
		CardType = ECardType::Power;
		ItemID = Other.PowerID;
		return this;
	}

	FCardDT& opAssign(FSurvivorDT Other)
	{
		if (Other.SurvivorID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Survivor;
			ItemID = Other.SurvivorID;
		}
		return this;
	}

	FCardDT& opAssign(FWeaponDT Other)
	{
		if (Other.WeaponID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Weapon;
			ItemID = Other.WeaponID;
		}
		return this;
	}

	FCardDT& opAssign(FAbilityDT Other)
	{
		if (Other.AbilityID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Ability;
			ItemID = Other.AbilityID;
		}
		return this;
	}
}