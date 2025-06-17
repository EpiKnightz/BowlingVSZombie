class URageAbility : UAbility
{
	URageResponseComponent RageResponsePtr;

	protected bool GetRageRespComp()
	{
		RageResponsePtr = URageResponseComponent::Get(InteractSystem.GetOwner());
		return IsValid(RageResponsePtr);
	}
}