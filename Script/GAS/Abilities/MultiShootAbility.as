class UMultiShootAbility : UShootBulletAbility
{
	private float SideShootAngle = 5;

	void OnAnimHitNotify() override
	{
		if (IsValid(AttackResponsePtr)
			&& AttackResponsePtr.DGetAttackLocation.IsBound()
			&& AttackResponsePtr.DGetAttackRotation.IsBound())
		{
			FVector Location = AttackResponsePtr.DGetAttackLocation.Execute();
			FRotator Rotation = AttackResponsePtr.DGetAttackRotation.Execute();
			for (int i = -2; i < 3; i++)
			{
				SpawnBullet(Location, Rotation + FRotator(0, SideShootAngle * i, 0));
			}
		}
	}
};