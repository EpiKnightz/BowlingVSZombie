class URageTrigger : UTrigger
{
	URageResponseComponent RageResponsePtr;

	protected bool GetRageRespComp(UAbility Ability)
	{
		RageResponsePtr = URageResponseComponent::Get(Ability.AbilitySystem.GetOwner());
		return IsValid(RageResponsePtr);
	}
};