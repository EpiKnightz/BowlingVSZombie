// const float DISTANCE_PER_SECOND = 500;
class UHookBackAbility : USpawnBulletAbility
{
	UFCTweenBPActionFloat FloatTween;
	USceneComponent Target;
	FVector OriginalTargetLoc;

	FVoidEvent OnHookEnd;

	void ActivateAbilityChild(AActor OtherActor) override
	{
		SpawnBullet(InteractSystem.GetOwner().GetActorLocation(), InteractSystem.GetOwner().GetActorRotation());
	}

	AActor SpawnBullet(FVector Location, FRotator Rotation) override
	{
		auto Actor = Cast<AHook>(Super::SpawnBullet(Location, Rotation));
		if (IsValid(Actor))
		{
			Actor.EOnOverlap.AddUFunction(this, n"OnHookOverlap");
			OnHookEnd.AddUFunction(Actor, n"HookComplete");
		}
		return Actor;
	}

	UFUNCTION()
	private void OnHookOverlap(AActor OtherActor)
	{
		Target = USceneComponent::Get(OtherActor);
		if (IsValid(Target))
		{
			OriginalTargetLoc = Target.GetWorldLocation();
			if (IsValid(FloatTween) && FloatTween.IsValid())
			{
				FloatTween.Stop();
				FloatTween.ApplyEasing.Clear();
			}
			float HookBackSpeed;
			AbilityData.AbilityParams.Find(GameplayTags::AbilityParam_Speed, HookBackSpeed);
			float HookTime = OriginalTargetLoc.DistXY(InteractSystem.GetOwner().GetActorLocation()) / HookBackSpeed;
			FloatTween = UFCTweenBPActionFloat::TweenFloat(0, 1, HookTime, EFCEase::Linear); // InOutQuad
			FloatTween.ApplyEasing.AddUFunction(this, n"GetOverHere");
			FloatTween.OnComplete.AddUFunction(this, n"OnAbilityEnd");
			FloatTween.Start();
		}
	}

	UFUNCTION()
	private void GetOverHere(float32 Value)
	{
		FVector MoveVector = CalculateOffset(InteractSystem.GetOwner().GetActorLocation(),
											 InteractSystem.GetOwner().GetActorRotation())
							 - OriginalTargetLoc;
		Target.SetWorldLocation(OriginalTargetLoc + MoveVector * Value);
	}

	void OnAbilityEnd() override
	{
		OnHookEnd.Broadcast();
		Super::OnAbilityEnd();
	}
}