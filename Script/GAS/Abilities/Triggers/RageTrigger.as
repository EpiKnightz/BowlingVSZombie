class URageTrigger : UTrigger
{
	URageResponseComponent RageResponsePtr;

	protected bool GetRageRespComp(UAbility Ability)
	{
		RageResponsePtr = URageResponseComponent::Get(Ability.InteractSystem.GetOwner());
		return IsValid(RageResponsePtr);
	}
};