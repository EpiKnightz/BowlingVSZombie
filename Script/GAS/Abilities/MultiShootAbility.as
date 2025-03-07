class UMultiShootAbility : UShootBulletAbility
{
	void OnAnimHitNotify() override
	{
		if (IsValid(AttackResponsePtr)
			&& AttackResponsePtr.DGetAttackLocation.IsBound()
			&& AttackResponsePtr.DGetAttackRotation.IsBound())
		{
			FVector Location = AttackResponsePtr.DGetAttackLocation.Execute();
			FRotator Rotation = AttackResponsePtr.DGetAttackRotation.Execute();
			MultiShoot(Location, Rotation);
			if (AttackResponsePtr.IsDualWield())
			{
				Location = AttackResponsePtr.DGetOffhandAttackLocation.Execute();
				MultiShoot(Location, Rotation);
			}
		}
	}

	void MultiShoot(FVector Location, FRotator Rotation)
	{
		float SideAngle, BulletCount, MinAngle;
		if (!AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Spread, SideAngle))
		{
			PrintWarning("Failed to find SideShootAngle in AbilityParams");
			SideAngle = 25;
		}
		if (!AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Count, BulletCount))
		{
			PrintWarning("Failed to find BulletCount in AbilityParams");
			BulletCount = 5;
		}
		MinAngle = -SideAngle / 2;
		SideAngle /= (BulletCount - 1);

		for (float i = 0; i < BulletCount; i += 1)
		{
			SpawnBullet(Location, Rotation + FRotator(0, MinAngle + SideAngle * i, 0));
		}
	}
};