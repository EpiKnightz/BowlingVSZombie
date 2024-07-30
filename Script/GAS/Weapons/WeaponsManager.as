class AWeaponsManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable WeaponDataTable;

	TMap<FGameplayTag, FWeaponDT> WeaponsMap;

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
	bool CreateWeapon(FGameplayTag WeaponID, AActor Target, UWeapon& WeaponPtr)
	{
		FWeaponDT WeaponData;
		if (WeaponsMap.Find(WeaponID, WeaponData))
		{
			if (WeaponID.MatchesTag(GameplayTags::Weapon_Rifle))
			{
				WeaponPtr = UWeaponGun::GetOrCreate(Target, WeaponID.TagName);
			}
			else if (WeaponID.MatchesTag(GameplayTags::Weapon_Pistol))
			{
				WeaponPtr = UWeaponPistol::GetOrCreate(Target, WeaponID.TagName);
			}
			else if (WeaponID.MatchesTag(GameplayTags::Weapon_Melee_Sword))
			{
				WeaponPtr = UWeaponSword::GetOrCreate(Target, WeaponID.TagName);
			}
			WeaponPtr.SetData(WeaponData);
			WeaponPtr.Setup();
			return true;
		}
		else
		{
			PrintError("CreateWeapon: WeaponID not found");
		}
		return false;
	}
};