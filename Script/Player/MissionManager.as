class AMissionManager : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	private UAchievementSubSystem AchievementSystem;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AchievementSystem = UAchievementSubSystem::Get();
		// TODO: Only for testing
		AchievementSystem.ResetAchievementStates();
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