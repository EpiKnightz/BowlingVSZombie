class AWeaponsManager : AActor
{
	UPROPERTY(BlueprintReadWrite)
	UDataTable WeaponDataTable;

	TMap<FGameplayTag, FWeaponDT> WeaponsData;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FWeaponDT> WeaponsArray;
		WeaponDataTable.GetAllRows(WeaponsArray);
		for (FWeaponDT Ability : WeaponsArray)
		{
			WeaponsData.Add(Ability.WeaponID, Ability);
		}
	}

	UFUNCTION()
	FWeaponDT GetWeaponData(FGameplayTag WeaponID)
	{
		FWeaponDT Weapon;
		if (WeaponsData.Find(WeaponID, Weapon) != false)
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
		if (WeaponsData.Find(WeaponID, WeaponData))
		{
			if (WeaponID.MatchesTag(GameplayTags::Weapon_Rifle))
			{
				WeaponPtr = UWeaponGun::GetOrCreate(Target, WeaponID.TagName);
			}
			else if (WeaponID.MatchesTag(GameplayTags::Weapon_Pistol))
			{
				WeaponPtr = UWeaponPistol::GetOrCreate(Target, WeaponID.TagName);
			}
			else if (WeaponID.MatchesTag(GameplayTags::Weapon_Sword))
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