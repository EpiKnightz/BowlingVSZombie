enum ETargetType
{
	Zombie,
	Player,
	Bowling,
	Survivor,
	Obstacle,
	Objective,
	Untargetable,
	Neutral
}

enum EDurationType
{
	Instant,
	Duration,
	Infinite
}

enum EElemental
{
	Fire,	   // Red
	Ice,	   // Blue
	Forest,	   // Green
	Earth,	   // Brown
	Lightning, // Yellow
	Corrosion, // Purple
	Void,	   // Grey
}

struct FStatusDT
{
	UPROPERTY()
	FGameplayTag EffectTag;

	UPROPERTY()
	FText Name;

	UPROPERTY(meta = (MultiLine = true))
	FText Description;

	UPROPERTY()
	FGameplayTagContainer DescriptionTags;

	UPROPERTY(EditAnywhere, Category = Appearance)
	UTexture2D Icon;

	UPROPERTY()
	TSubclassOf<UStatusComponent> StatusEffectClass;

	UPROPERTY()
	ETargetType TargetType = ETargetType::Zombie;

	UPROPERTY()
	EDurationType DurationType = EDurationType::Duration;

	/// Duration of the status effect in seconds.
	UPROPERTY(meta = (EditCondition = "DurationType == EDurationType::Duration", EditConditionHides))
	float Duration;

	UPROPERTY()
	EStackingRule StackingRule = EStackingRule::None;

	UPROPERTY()
	TMap<FGameplayTag, float> AffectedAttributes;

	/// Particle system to display when this status effect is active.
	UPROPERTY()
	UNiagaraSystem StatusVFX;

	/// Particle system to display when this status effect is active.
	UPROPERTY()
	UNiagaraSystem StatusEndVFX;
}