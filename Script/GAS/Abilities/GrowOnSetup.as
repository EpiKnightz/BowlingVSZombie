class UGrowOnSetupAbility : UAbility
{
	protected UFCTweenBPActionFloat FloatTween;

	bool SetupAbilityChild() override
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
			return true;
		}
		return false;
	}
}