delegate void FIntDelegate(int Value);
delegate int FInt2IntDelegate(int Value);
delegate void FVoidDelegate();
delegate void FNameDelegate(FName Name);
delegate void FIntNameDelegate(int Value, FName Name);
delegate void FActorDelegate(AActor OtherActor);
delegate void FFloatDelegate(float Value);
delegate void FFTextDelegate(FText Message);
delegate void FNiagaraDelegate(UNiagaraSystem System);
delegate void FStatusDelegate(EEffectType status);

event void FVoidEvent();
event void FIntEvent(int Value);
event void FNameEvent(FName Name);
event void FFloatEvent(float Value);

namespace Utilities
{
	FName StatusEnumToFName(EEffectType Status)
	{
		switch (Status)
		{
			case EEffectType::Fire:
				return n"Item_0";
			case EEffectType::Chill:
				return n"Item_1";
			case EEffectType::Freeze:
				return n"Item_2";
			case EEffectType::Poison:
				return n"Poison";
			case EEffectType::Rupture:
				return n"Rupture";
			default:
				return n"None";
		}
	}

	FName StatusEnumToComponentName(EEffectType Status)
	{
		switch (Status)
		{
			case EEffectType::Fire:
				return n"BurningComponent";
			case EEffectType::Chill:
				return n"ChillingComponent";
			case EEffectType::Poison:
				return n"PoisoningComponent";
			case EEffectType::Rupture:
				return n"RupturingComponent";
			default:
				return n"None";
		}
	}
}
