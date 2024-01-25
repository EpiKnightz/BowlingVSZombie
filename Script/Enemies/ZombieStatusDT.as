struct FZombieStatusDT
{
	/// The status effect currently applied to the zombie.
	UPROPERTY()
	EStatus StatusEffect;

	/// Particle system to display when this status effect is active.
	// UPROPERTY()
	// UParticleSystem StatusVFX;
	UPROPERTY()
	UNiagaraSystem StatusVFX;

	/// Duration of the status effect in seconds.
	UPROPERTY()
	float Duration;

	/// 1st parameter for the status effect. Usually the damage amount.
	UPROPERTY()
	float Param1;

	/// 2nd parameter for the status effect. Usually the percentage of effectiveness.
	UPROPERTY()
	float Param2;
};
