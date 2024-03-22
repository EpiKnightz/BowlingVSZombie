delegate void FIntDelegate(int Value);
delegate int FInt2IntDelegate(int Value);
delegate void FVoidDelegate();
delegate void FNameDelegate(FName Name);
delegate void FIntNameDelegate(int Value, FName Name);
delegate void FActorDelegate(AActor OtherActor);
delegate void FFloatDelegate(float Value);
delegate void FFTextDelegate(FText Message);
delegate void FNiagaraDelegate(UNiagaraSystem System);
delegate void FStatusDelegate(EDamageType status);

event void FVoidEvent();
event void FIntEvent(int Value);
event void FNameEvent(FName Name);
event void FFloatEvent(float Value);

namespace Utilities
{
	FName StatusEnumToFName(EDamageType Status)
	{
		switch (Status)
		{
			case EDamageType::Fire:
				return n"Item_0";
			case EDamageType::Chill:
				return n"Item_1";
			case EDamageType::Freeze:
				return n"Item_2";
			case EDamageType::Poison:
				return n"Poison";
			case EDamageType::Rupture:
				return n"Rupture";
			default:
				return n"None";
		}
	}

	FName StatusEnumToComponentName(EDamageType Status)
	{
		switch (Status)
		{
			case EDamageType::Fire:
				return n"BurningComponent";
			case EDamageType::Chill:
				return n"ChillingComponent";
			case EDamageType::Poison:
				return n"PoisoningComponent";
			case EDamageType::Rupture:
				return n"RupturingComponent";
			default:
				return n"None";
		}
	}
}
