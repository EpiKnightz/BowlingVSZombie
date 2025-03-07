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
	FWeaponDT CreateWeaponFromTag(FGameplayTag WeaponTag, AActor Target, UWeapon& WeaponPtr, bool bIsMainWeapon = true)
	{
		FWeaponDT WeaponData;
		if (WeaponsMap.Find(WeaponTag, WeaponData))
		{
			CreateWeapon(WeaponData, Target, WeaponPtr, bIsMainWeapon);
		}
		else
		{
			PrintError("CreateWeaponFromTag: Weapon Tag not found");
		}
		return WeaponData;
	}

	// IMPORTANT: WeaponPtr should be nullptr
	UFUNCTION()
	void CreateWeapon(FWeaponDT WeaponData, AActor Target, UWeapon& WeaponPtr, bool bIsMainWeapon = true)
	{
		if (WeaponPtr != nullptr)
		{
			PrintError("CreateWeapon: WeaponPtr should be nullptr");
			return;
		}

		FName WeaponName = FName("Weapon_" + bIsMainWeapon);

		if (WeaponData.WeaponID.MatchesTag(GameplayTags::Weapon_Range))
		{
			WeaponPtr = UWeaponGun::Create(Target, WeaponName);
		}
		else if (WeaponData.WeaponID.MatchesTag(GameplayTags::Weapon_Melee))
		{
			WeaponPtr = UWeaponSword::Create(Target, WeaponName);
		}
		WeaponPtr.SetData(WeaponData, bIsMainWeapon);
		WeaponPtr.Setup(bIsMainWeapon);
	}
};