class UCustomAnimInst : UAnimInstance
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsMirror = true;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	float AnimPlayRate = 1;
}
