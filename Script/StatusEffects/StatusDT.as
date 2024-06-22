enum ETargetType
{
	Zombie,
	Player,
	Bowling,
	Survivor,
	Untargetable,
	Neutral
}

enum EDurationType
{
	Instant,
	Duration,
	Infinite
}

struct FStatusDT
{
	UPROPERTY()
	FGameplayTag EffectTag;

	UPROPERTY()
	ETargetType TargetType = ETargetType::Zombie;

	UPROPERTY()
	EDurationType DurationType = EDurationType::Duration;

	/// Duration of the status effect in seconds.
	UPROPERTY(meta = (EditCondition = "DurationType == EDurationType::Duration", EditConditionHides))
	float Duration;

	UPROPERTY()
	EStackingRule StackingRule = EStackingRule::None;

	/// Particle system to display when this status effect is active.
	UPROPERTY()
	UNiagaraSystem StatusVFX;

	/// Particle system to display when this status effect is active.
	UPROPERTY()
	UNiagaraSystem StatusEndVFX;

	UPROPERTY()
	TMap<FGameplayTag, float> AffectedAttributes;
}