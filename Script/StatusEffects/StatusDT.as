enum ETargetType
{
	Zombie,
	Player,
	Both
}

struct FStatusDT
{
	/// The status effect currently applied to the zombie.
	// UPROPERTY()
	// EEffectType EffectType;

	UPROPERTY()
	FGameplayTag EffectTag;

	UPROPERTY()
	ETargetType TargetType = ETargetType::Zombie;

	UPROPERTY()
	EStackingRule StackingRule = EStackingRule::None;

	/// Particle system to display when this status effect is active.
	UPROPERTY()
	UNiagaraSystem StatusVFX;

	/// Duration of the status effect in seconds.
	UPROPERTY()
	float Duration;

	UPROPERTY()
	TMap<FGameplayTag, float> AffectedAttributes;
}