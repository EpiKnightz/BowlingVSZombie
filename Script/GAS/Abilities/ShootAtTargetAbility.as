class UShootAtTargetAbility : UAbility
{
	AActor TargetActor;

	bool SetupAbilityChild() override
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse))
		{
			GetAbilityData(GameplayTags::Ability_ShootAtTarget);
			if (AbilityData.AbilityID.IsValid())
			{
				AttackResponse.EOnBeginOverlapEvent.AddUFunction(this, n"TriggerOnOverlap");
				AttackResponse.EOnAnimHitNotify.AddUFunction(this, n"OnAnimHitNotify");
				return true;
			}
		}
		return false;
	}

	UFUNCTION()
	void TriggerOnOverlap(AActor OtherActor)
	{
		ABowling pawn = Cast<ABowling>(OtherActor);
		if (pawn != nullptr)
		{
			pawn.EOnHit.AddUFunction(this, n"OnHit");
		}
	}

	UFUNCTION()
	void OnHit(AActor OtherActor)
	{
		auto TargetResponse = UTargetResponseComponent::Get(OtherActor);
		if (IsValid(TargetResponse))
		{
			if (TargetResponse.TargetType == ETargetType::Zombie)
			{
				auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
				if (IsValid(AttackResponse))
				{
					TargetActor = OtherActor;
					AttackResponse.DPlayAttackAnim.ExecuteIfBound();
				}
			}
		}
	}

	UFUNCTION()
	private void OnAnimHitNotify()
	{
		if (IsValid(TargetActor))
		{
			auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
			if (IsValid(AttackResponse) && AttackResponse.DGetAttackLocation.IsBound() && AttackResponse.DGetAttackRotation.IsBound())
			{
				AttackResponse.GetOwner().SetActorRotation(FRotator::MakeFromX(TargetActor.GetActorLocation() - AttackResponse.DGetSocketLocation.ExecuteIfBound(n"RightPistol"))
														   + FRotator(0, 180, 0));
				SpawnActor(AbilityData.ActorTemplate, AttackResponse.DGetAttackLocation.Execute(), AttackResponse.DGetAttackRotation.Execute());
			}
		}
	}

	void StopAbility() override
	{
		auto AttackResponse = UAttackResponseComponent::Get(AbilitySystem.GetOwner());
		if (IsValid(AttackResponse))
		{
			AttackResponse.EOnBeginOverlapEvent.UnbindObject(this);
			AttackResponse.EOnAnimHitNotify.UnbindObject(this);

			// What about OnHit function? Guess we'll find out...
		}
	}
};