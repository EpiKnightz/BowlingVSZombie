class UStatusAbility : UAbility
{
	UStatusResponseComponent StatusResponsePtr;

	protected bool GetStatusRespComp()
	{
		StatusResponsePtr = UStatusResponseComponent::Get(InteractSystem.GetOwner());
		return IsValid(StatusResponsePtr);
	}
}