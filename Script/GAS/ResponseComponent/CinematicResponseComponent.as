class UCinematicResponseComponent : UResponseComponent
{
	FVoidEvent EOnImpact;

	UFUNCTION()
	void NotifyImpact()
	{
		EOnImpact.Broadcast();
	}
};