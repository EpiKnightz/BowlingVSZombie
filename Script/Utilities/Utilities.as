delegate void FBoolDelegate(bool bValue);
delegate void FIntDelegate(int Value);
delegate int FInt2IntDelegate(int Value);
delegate float FFloat2FloatDelegate(float Value);
delegate float32 FFloat2Float32Delegate(float32 Value);
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
delegate FRotator FRotatorReturnDelegate();
delegate FVector FVectorReturnDelegate();
delegate FVector FName2VectorDelegate(FName Name);
delegate void FColorDelegate(FLinearColor Value);
delegate void FColorBoolDelegate(FLinearColor Value, bool Bool);
delegate bool FSurvivor2BoolDelegate(ASurvivor& Survivor);
delegate FSurvivorDT FTagSurvivor2DataDelegate(FGameplayTag SurvivorID, ASurvivor& SpawnedActor);
delegate FWeaponDT FTagWeapon2DataDelegate(FGameplayTag WeaponTag, AActor Target, UWeapon& WeaponPtr, bool bIsMainWeapon = true);;
delegate FWeaponDT FTag2WeaponDataDelegate(FGameplayTag WeaponTag);
delegate FAbilityDT FTag2AbilityDataDelegate(FGameplayTag AbilityTag);
delegate void FIntCardDelegate(int Value, FCardDT Card);
delegate void FTagAbilitySystemDelegate(FGameplayTagContainer AbilitiesContainer, ULiteAbilitySystem& AbilitySystem);
delegate FSurvivorDT FTagInt2SurvivorDataDelegate(FGameplayTag Tag, int Value);
delegate void FCardDTDelegate(FCardDT Value);
delegate void FTexture2DDelegate(UStatusComponent StatComp, UTexture2D Icon);
delegate FName FGameplayTag2FNameDelegate(FGameplayTag KeywordTag);
// delegate bool FClass2BoolDelegate(UClass iClass);
// delegate void FClassDelegate(UClass iClass);
// delegate void FWidgetDelegate(UUserWidget WidgetClass);
// delegate void FStringTextDelegate(FString RewardName, FText Description);

event void FVectorEvent(FVector Value);
event void FBoolEvent(bool bValue);
event void FVectorRotatorEvent(FVector Value, FRotator Rotator);
event void FVectorBoolEvent(FVector Value, bool Bool);
event void FVoidEvent();
event void FActorEvent(AActor OtherActor);
event void FActorVectorEvent(AActor OtherActor, FVector Vector);
event void FIntEvent(int Value);
event void FNameEvent(FName Name);
event void FFloatEvent(float Value);
event void FNameFloatEvent(FName Name, float Value);
event void FNameModifierEvent(FName Name, UModifier Modifier);
event void FNameFloat32Event(FName Name, float32 Value);
event void FHitResultEvent(FHitResult HitResult);
event void FGTagContainerEvent(FGameplayTagContainer TagContainer);
event void FGameplayTagEvent(FGameplayTag Tag);
event void FTagStatusCompEvent(FGameplayTag Tag, UStatusComponent Target);
event void FCardDTEvent(FCardDT Value);
event void FBowlingEvent(ABowling& Bowling);
event void FZombieEvent(AZombie& Bowling);
event void FSurvivorEvent(ASurvivor& Bowling);

namespace Utilities
{

}
