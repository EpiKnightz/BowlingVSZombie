class URageAbility : UAbility
{
	URageResponseComponent RageResponsePtr;

	protected bool GetRageRespComp()
	{
		RageResponsePtr = URageResponseComponent::Get(AbilitySystem.GetOwner());
		return IsValid(RageResponsePtr);
	}
}