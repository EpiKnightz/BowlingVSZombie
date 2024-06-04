delegate void FIntDelegate(int Value);
delegate int FInt2IntDelegate(int Value);
delegate float FFloat2FloatDelegate(float Value);
delegate bool FFloat2BoolDelegate(float Value);
delegate void FVoidDelegate();
delegate void FNameDelegate(FName Name);
delegate void FIntNameDelegate(int Value, FName Name);
delegate void FFloatNameDelegate(float Value, FName Name);
delegate void FActorDelegate(AActor OtherActor);
delegate void FFloatDelegate(float Value);
delegate void FFTextDelegate(FText Message);
delegate void FNiagaraDelegate(UNiagaraSystem System);
delegate void FGameplayTagDelegate(FGameplayTagContainer TagContainer);
delegate bool FBoolReturnDelegate();
delegate void FObjectIntDelegate(const UObject Object, int ID);
delegate void FModDelegate(UModifier Calculation);
delegate void FVectorDelegate(FVector Value);

event void FVoidEvent();
event void FActorEvent(AActor OtherActor);
event void FActorVectorEvent(AActor OtherActor, FVector Vector);
event void FIntEvent(int Value);
event void FNameEvent(FName Name);
event void FFloatEvent(float Value);
event void FNameFloatEvent(FName Name, float Value);
event void FNameModifierEvent(FName Name, UModifier Modifier);
event void FNameFloat32Event(FName Name, float32 Value);
event void FGameplayTagEvent(FGameplayTagContainer TagContainer);

namespace Utilities
{

}
