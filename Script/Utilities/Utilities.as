delegate void FIntDelegate(int Value);
delegate int FInt2IntDelegate(int Value);
delegate void FVoidDelegate();
delegate void FNameDelegate(FName Name);
delegate void FIntNameDelegate(int Value, FName Name);
delegate void FActorDelegate(AActor OtherActor);
delegate void FFloatDelegate(float Value);
delegate void FFTextDelegate(FText Message);
delegate void FNiagaraDelegate(UNiagaraSystem System);
delegate void FStatusDelegate(EStatus status);

event void FVoidEvent();
event void FIntEvent(int Value);
event void FNameEvent(FName Name);
event void FFloatEvent(float Value);

namespace Utilities
{
	FName StatusEnumToFName(EStatus Status)
	{
		switch (Status)
		{
			case EStatus::Fire:
				return n"Item_0";
			case EStatus::Chill:
				return n"Item_1";
			case EStatus::Freeze:
				return n"Item_2";
			case EStatus::Poison:
				return n"Poison";
			case EStatus::Rupture:
				return n"Rupture";
			default:
				return n"None";
		}
	}

	FName StatusEnumToComponentName(EStatus Status)
	{
		switch (Status)
		{
			case EStatus::Fire:
				return n"BurningComponent";
			case EStatus::Chill:
				return n"ChillingComponent";
			case EStatus::Poison:
				return n"PoisoningComponent";
			case EStatus::Rupture:
				return n"RupturingComponent";
			default:
				return n"None";
		}
	}
}
