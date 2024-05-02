class UMoveableAttrSet : ULiteAttrSet
{
	UPROPERTY(BlueprintReadWrite, Category = "Moveable Attribute")
	FAngelscriptGameplayAttributeData MoveSpeed;

	UMoveableAttrSet()
	{
		MoveSpeed.Initialize(100);
	}
};