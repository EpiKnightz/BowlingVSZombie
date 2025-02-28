class UCustomAnimInst : UAnimInstance
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	bool bIsMirror = false;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	float DualWieldRate = 0;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, VisibleAnywhere, meta = (AllowPrivateAccess = "true"))
	float AnimPlayRate = 1;
}
