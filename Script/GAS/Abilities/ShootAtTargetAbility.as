class UShootAtTargetAbility : UShootBulletAbility
{
	protected AActor TargetActor;

	void ActivateAbilityChild(AActor OtherActor) override
	{
		TargetActor = OtherActor;

		if (IsValid(TargetActor)
			&& IsValid(AttackResponsePtr)
			&& AttackResponsePtr.DGetSocketLocation.IsBound())
		{
			AbilitySystem.GetOwner().SetActorRotation(FRotator::MakeFromX(TargetActor.GetActorLocation()
																		  - AttackResponsePtr.DGetSocketLocation.ExecuteIfBound(n"RightHand"))
													  + FRotator(0, 180, 0));
		}

		Super::ActivateAbilityChild(OtherActor);
	}
};