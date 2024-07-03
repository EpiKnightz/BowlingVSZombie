class UMultiShootOnOverlapAbility : UShootOnOverlapAbility
{
	float SideShootAngle = 15;

	void OnAnimHitNotify() override
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse) && AttackResponse.DGetAttackLocation.IsBound() && AttackResponse.DGetAttackRotation.IsBound())
		{
			FVector Location = AttackResponse.DGetAttackLocation.Execute();
			FRotator Rotation = AttackResponse.DGetAttackRotation.Execute();
			SpawnActor(AbilityData.ActorTemplate, Location, Rotation + FRotator(0, SideShootAngle, 0));
			SpawnActor(AbilityData.ActorTemplate, Location, Rotation);
			SpawnActor(AbilityData.ActorTemplate, Location, Rotation - FRotator(0, SideShootAngle, 0));
		}
	}
};