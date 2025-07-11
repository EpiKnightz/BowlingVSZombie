enum ECardType
{
	None,
	Power,
	Survivor,
	Ability,
	Weapon,
	Bowling
}

enum ERarity
{
	Null = -1,
	Common = 0,	   // White
	Rare = 1,	   // Blue
	Epic = 2,	   // Purple
	Legendary = 3, // Gold
	Mythic = 4	   // Cosmetic Only, Red
}

struct FCardDT
{
	UPROPERTY()
	FGameplayTag ItemID;

	UPROPERTY()
	FString Name = "Bouncer Power";

	UPROPERTY()
	FText Description = FText::FromString("After 1st bounce, Increase bowling's damage by 1.5x");

	UPROPERTY()
	UTexture2D Icon;

	UPROPERTY(meta = (ClampMin = "1", ClampMax = "5", UIMin = "1", UIMax = "5"))
	int Star = 1;

	UPROPERTY()
	int Cost = 0;

	UPROPERTY()
	ERarity Rarity = ERarity::Common;

	UPROPERTY()
	FGameplayTagContainer DescriptionTags;

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
			Cost = Other.Cost;
			Star = Other.Star;
			Rarity = Other.Rarity;
			DescriptionTags = Other.DescriptionTags;
		}
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
			Cost = Other.Cost;
			Star = Other.Star;
			Rarity = Other.Rarity;
			DescriptionTags = Other.DescriptionTags;
		}
		return this;
	}

	FCardDT(FWeaponDT Other)
	{
		if (Other.WeaponID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Weapon;
			ItemID = Other.WeaponID;
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
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
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
		return this;
	}

	FCardDT(FAbilityDT Other)
	{
		if (Other.AbilityID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Ability;
			ItemID = Other.AbilityID;
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
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
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
		return this;
	}

	FCardDT(FBallDT Other)
	{
		if (Other.BowlingID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Bowling;
			ItemID = Other.BowlingID;
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
	}

	FCardDT& opAssign(FBallDT Other)
	{
		if (Other.BowlingID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Bowling;
			ItemID = Other.BowlingID;
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
		return this;
	}

	FCardDT(FPowerDT Other)
	{
		if (Other.PowerID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Power;
			ItemID = Other.PowerID;
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
	}

	FCardDT& opAssign(FPowerDT Other)
	{
		if (Other.PowerID.IsValid())
		{
			Name = Other.Name;
			Description = Other.Description;
			Icon = Other.Icon;
			CardType = ECardType::Power;
			ItemID = Other.PowerID;
			Cost = Other.Cost;
			Star = Other.Star;
			DescriptionTags = Other.DescriptionTags;
		}
		return this;
	}
}