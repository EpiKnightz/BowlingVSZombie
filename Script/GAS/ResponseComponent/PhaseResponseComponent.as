enum EPhaseHPType
{
	Equally,
	Custom,
}

class UPhaseResponseComponent : UResponseComponent
{
	int NumberOfPhases = 1;
	int CurrentPhase = 0;
	protected TArray<UModifierObject> Lv1Modifiers;
	protected TArray<UModifierObject> Lv2Modifiers;
	protected TArray<UModifierObject> Lv3Modifiers;
	TArray<float> PhaseHPSteps;

	FIntEvent EOnPhaseUp;

	void SetupPhaseData(int Phases, TArray<UModifierObject> Lv1, TArray<UModifierObject> Lv2, TArray<UModifierObject> Lv3, EPhaseHPType Type = EPhaseHPType::Equally, bool bUpdateFirstPhase = true)
	{
		if (Phases > 3)
		{
			PrintError("Too many phases, game not supported");
			return;
		}
		NumberOfPhases = Phases;
		CurrentPhase = 0; // 0, 1, 2
		if (bUpdateFirstPhase)
		{
			AddModifiers(Lv1);
		}
		else
		{
			Lv1Modifiers = Lv1;
		}
		Lv2Modifiers = Lv2;
		Lv3Modifiers = Lv3;

		switch (Type)
		{
			case EPhaseHPType::Equally:
			{
				for (int i = 1; i < Phases; i++)
				{
					PhaseHPSteps.Add(1 - (1.0 * i / Phases));
				}
				break;
			}
			default:
			{
				Print("To be setup manually");
			}
		}
	}

	void SetupHPSteps(float Step1, float Step2)
	{
		if (NumberOfPhases > 1)
		{
			PhaseHPSteps.Add(Step1);
		}
		if (NumberOfPhases > 2)
		{
			PhaseHPSteps.Add(Step2);
		}
	}

	bool CheckForRankUp(float HPPercentage)
	{
		if (NumberOfPhases > 1 && CurrentPhase < NumberOfPhases - 1)
		{
			if (HPPercentage <= PhaseHPSteps[CurrentPhase])
			{
				if (CurrentPhase == 0)
				{
					AddModifiers(Lv2Modifiers);
				}
				else if (CurrentPhase == 1)
				{
					AddModifiers(Lv3Modifiers);
				}
				CurrentPhase++;
				EOnPhaseUp.Broadcast(CurrentPhase);
			}
			return true;
		}
		return false;
	}

	void AddModifiers(TArray<UModifierObject> Modifiers)
	{
		if (Modifiers.Num() > 0)
		{
			for (int i = 0; i < Modifiers.Num(); i++)
			{
				if (Modifiers[i] != nullptr)
				{
					Modifiers[i].AddToAbilitySystem(AbilitySystem);
				}
				else
				{
					PrintError("Null modifier object number " + i);
				}
			}
		}
	}
};