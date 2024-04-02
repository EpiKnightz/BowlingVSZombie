enum ETargetType
{
	Zombie,
	Player,
	Both
}

struct FStatusDT
{
	/// The status effect currently applied to the zombie.
	UPROPERTY()
	EEffectType EffectType;

	UPROPERTY()
	ETargetType TargetType = ETargetType::Zombie;

	/// Particle system to display when this status effect is active.
	UPROPERTY()
	UNiagaraSystem StatusVFX;

	/// Duration of the status effect in seconds.
	UPROPERTY()
	float Duration;

	/// 1st parameter for the status effect. Usually the damage amount.
	UPROPERTY()
	float Param1; // Slow amount

	/// 2nd parameter for the status effect. Usually the percentage of effectiveness.
	UPROPERTY()
	float Param2; // Times to freeze
}