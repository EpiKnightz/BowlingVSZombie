class UAdditiveMod : UModifier
{
	void DoCalculateChildren(const UInteractSystem InteractSystem, float32& SourceValue) override
	{
		// for (int i = 0; i < Params.Num(); i++)
		//{
		SourceValue += Params[0];
		//}
	}

	bool IsValidInput(float SourceValue) override
	{
		return Params.Num() > 0;
	}
};