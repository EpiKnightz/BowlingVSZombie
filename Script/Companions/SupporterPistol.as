class ASupporterPistol : ASupporterGun
{
	UFUNCTION(BlueprintOverride, Meta = (NoSuperCall))
	void ConstructionScript()
	{
		RightHandWp.AttachTo(CompanionSkeleton, n"RightPistol");
	}
}
