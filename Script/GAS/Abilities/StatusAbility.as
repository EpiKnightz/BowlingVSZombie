class UStatusAbility : UAbility
{
	UStatusResponseComponent StatusResponsePtr;

	protected bool GetStatusRespComp()
	{
		StatusResponsePtr = UStatusResponseComponent::Get(AbilitySystem.GetOwner());
		return IsValid(StatusResponsePtr);
	}
}