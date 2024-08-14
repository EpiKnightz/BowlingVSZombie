class AWeaponsManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable WeaponDataTable;

	TMap<FGameplayTag, FWeaponDT> WeaponsMap;

	// Only be used in case of random weapon. If created directly, use weaponsMap instead.
	FItemPoolConfigDT ItemPoolConfig;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FWeaponDT> WeaponsArray;
		WeaponDataTable.GetAllRows(WeaponsArray);
		for (FWeaponDT Weapon : WeaponsArray)
		{
			WeaponsMap.Add(Weapon.WeaponID, Weapon);
		}
	}

	UFUNCTION()
	FWeaponDT GetWeaponData(FGameplayTag WeaponID)
	{
		FWeaponDT Weapon;
		if (WeaponsMap.Find(WeaponID, Weapon) != false)
		{
			return Weapon;
		}
		else
		{
			PrintError("GetWeaponData: WeaponID not found");
			return Weapon;
		}
	}

	UFUNCTION()
	private void AddCard(FCardDT CardData)
	{
		if (CardData.CardType == ECardType::Weapon)
		{
			ItemPoolConfig.AddUniqueTag(CardData.ItemID);
		}
	}

	UFUNCTION()
	FWeaponDT CreateRandomWeapon(AActor Target)
	{
		UWeapon WeaponPtr;
		return CreateWeaponFromTag(ItemPoolConfig.GetRandomTag(), Target, WeaponPtr);
	}

	UFUNCTION()
	FWeaponDT CreateWeaponFromTag(FGameplayTag WeaponTag, AActor Target, UWeapon& WeaponPtr)
	{
		FWeaponDT WeaponData;
		if (WeaponsMap.Find(WeaponTag, WeaponData))
		{
			CreateWeapon(WeaponData, Target, WeaponPtr);
		}
		else
		{
			PrintError("CreateRandomWeapon: Weapon Tag not found");
		}
		return WeaponData;
	}

	// IMPORTANT: WeaponPtr should be nullptr
	UFUNCTION()
	void CreateWeapon(FWeaponDT WeaponData, AActor Target, UWeapon& WeaponPtr)
	{
		if (WeaponPtr != nullptr)
		{
			PrintError("CreateWeapon: WeaponPtr should be nullptr");
			return;
		}

		if (WeaponData.WeaponID.MatchesTag(GameplayTags::Weapon_Range_Rifle))
		{
			WeaponPtr = UWeaponGun::Create(Target, WeaponData.WeaponID.TagName);
		}
		else if (WeaponData.WeaponID.MatchesTag(GameplayTags::Weapon_Range_Pistol))
		{
			WeaponPtr = UWeaponPistol::Create(Target, WeaponData.WeaponID.TagName);
		}
		else if (WeaponData.WeaponID.MatchesTag(GameplayTags::Weapon_Melee_Sword))
		{
			WeaponPtr = UWeaponSword::Create(Target, WeaponData.WeaponID.TagName);
		}
		else if (WeaponData.WeaponID.MatchesTag(GameplayTags::Weapon_Range_Shotgun))
		{
			WeaponPtr = UWeaponShotGun::Create(Target, WeaponData.WeaponID.TagName);
		}
		WeaponPtr.SetData(WeaponData);
		WeaponPtr.Setup();
	}
};