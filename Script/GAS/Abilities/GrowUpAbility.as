class UGrowUpAbility : UAbility
{
	protected UFCTweenBPActionFloat FloatTween;

	void ActivateAbilityChild(AActor Target) override
	{
		auto Survivor = Cast<ASurvivor>(AbilitySystem.GetOwner());
		if (IsValid(Survivor))
		{
			if (IsValid(FloatTween) && FloatTween.IsValid())
			{
				FloatTween.Stop();
				FloatTween.ApplyEasing.Clear();
			}
			FloatTween = UFCTweenBPActionFloat::TweenFloat(1, 2, 0.5f, EFCEase::OutElastic);
			FloatTween.ApplyEasing.AddUFunction(Survivor, n"SetScaleFloat");
			FloatTween.Start();
		}
	}
}