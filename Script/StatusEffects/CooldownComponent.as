
class UCooldownComponent : UStatusComponent
{
	default TargetType = EStatusTargetType::Player;

	void DoInitChildren(float iParam1, float iParam2) override
	{
	}

	void EndStatusEffect() override
	{
		Super::EndStatusEffect();
	}
};