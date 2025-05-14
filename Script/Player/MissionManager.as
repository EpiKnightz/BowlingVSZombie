class AMissionManager : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	private UAchievementSubSystem AchievementSystem;

	FAchivementArrayEvent EOnTutorialMissionUpdate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AchievementSystem = UAchievementSubSystem::Get();
		// TODO: Only for testing
		AchievementSystem.ResetAchievementStates();
	}

	UFUNCTION()
	void UpdateTutorialMission()
	{
		TArray<FAchievementData> MissionArray;
		TArray<FAchievementStates> MissionStateArray;
		if (AchievementSystem.GetAllAchievementWithTag(n"Tutorial", MissionArray, MissionStateArray) > 0)
		{
			EOnTutorialMissionUpdate.Broadcast(MissionArray, MissionStateArray);
		}
	}

	UFUNCTION()
	void AddProgressToMissionTag(float Progress, FName MissionTag)
	{
		TArray<FAchievementData> MissionList = AchievementSystem.GetAllAchievementDataWithTag(MissionTag);
		for (FAchievementData Achievement : MissionList)
		{
			AchievementSystem.AddAchievementProgress(Achievement.Key, Progress);
		}
	}
};