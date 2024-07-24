enum ECardType
{
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
	FName ItemID;

	ECardType CardType;

	void SetID(FName ID)
	{
		ItemID = ID;
	}

	FCardDT& opAssign(FPowerDT Other)
	{
		Name = Other.Name;
		Description = Other.Description;
		Icon = Other.Icon;
		CardType = ECardType::Power;
		return this;
	}

	FCardDT& opAssign(FSurvivorDT Other)
	{
		Name = Other.Name;
		Description = Other.Description;
		// Icon = Other.Icon;
		CardType = ECardType::Survivor;
		return this;
	}

	FCardDT& opAssign(FWeaponDT Other)
	{
		Name = Other.Name;
		Description = Other.Description;
		// Icon = Other.Icon;
		CardType = ECardType::Survivor;
		return this;
	}

	FCardDT& opAssign(FAbilityDT Other)
	{
		Name = Other.Name;
		Description = Other.Description;
		// Icon = Other.Icon;
		CardType = ECardType::Survivor;
		return this;
	}
}