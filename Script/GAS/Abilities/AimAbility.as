class UAimAbility : UAbility
{

	// Is this really needed? Since there is only one player, and the abiliy won't be used anywhere else

	// UInstancedStaticMeshComponent PredictLine;
	// float PredictSimTime = 1;
	// float BowlingPowerMultiplier = 1;

	// void StopAbility() override
	// {
	// 	PredictLine.ClearInstances();
	// }

	// UFUNCTION(BlueprintCallable)
	// void DrawPredictLine()
	// {
	// 	PredictLine.ClearInstances();
	// 	FPredictProjectilePathParams PredictProjectilePathParams;
	// 	PredictProjectilePathParams.StartLocation = GetActorLocation();
	// 	PredictProjectilePathParams.bTraceWithCollision = true;
	// 	PredictProjectilePathParams.TraceChannel = ECollisionChannel::ECC_Pawn;
	// 	FVector predictVector = -GetActorForwardVector() * CurrentBallData.BowlingSpeed * BowlingPowerMultiplier * 1.5;
	// 	PredictProjectilePathParams.LaunchVelocity = predictVector;
	// 	PredictProjectilePathParams.OverrideGravityZ = 0.0001f;
	// 	PredictProjectilePathParams.ProjectileRadius = 36;
	// 	PredictProjectilePathParams.MaxSimTime = PredictSimTime;
	// 	// PredictProjectilePathParams.DrawDebugType = EDrawDebugTrace::ForDuration;
	// 	// PredictProjectilePathParams.DrawDebugTime = 5;
	// 	//  PredictProjectilePathParams.bTraceWithCollision = false;
	// 	TArray<TObjectPtr<AActor>> ignoreList;
	// 	ignoreList.Add(this);
	// 	PredictProjectilePathParams.ActorsToIgnore = ignoreList;
	// 	FPredictProjectilePathResult PredictProjectilePathResult;
	// 	Gameplay::Blueprint_PredictProjectilePath_Advanced(PredictProjectilePathParams, PredictProjectilePathResult);

	// 	for (int i = 1; i < PredictProjectilePathResult.PathData.Num() - 1; i++)
	// 	{
	// 		FTransform transform = FTransform::Identity;
	// 		transform.SetLocation(PredictProjectilePathResult.PathData[i].Location);
	// 		transform.SetScale3D(FVector(0.15f));
	// 		PredictLine.AddInstance(transform);
	// 	}

	// 	if (PredictProjectilePathResult.HitResult.GetActor() != nullptr && PredictProjectilePathResult.HitResult.Component.GetCollisionObjectType() == ECollisionChannel::ECC_WorldStatic)
	// 	{
	// 		FTransform transform = FTransform::Identity;
	// 		transform.SetLocation(PredictProjectilePathResult.HitResult.Location);
	// 		transform.SetScale3D(FVector(0.25f));
	// 		PredictLine.AddInstance(transform);

	// 		// Draw a seconde line for the bounce
	// 		PredictProjectilePathParams.MaxSimTime = Math::Clamp(PredictSimTime * 0.8 - PredictProjectilePathResult.PathData[PredictProjectilePathResult.PathData.Num() - 1].Time, 0.2, PredictSimTime);
	// 		PredictProjectilePathParams.LaunchVelocity = Math::GetReflectionVector(predictVector, PredictProjectilePathResult.HitResult.Normal) * 0.6;
	// 		PredictProjectilePathParams.StartLocation = PredictProjectilePathResult.HitResult.Location + PredictProjectilePathParams.LaunchVelocity.GetSafeNormal();
	// 		FPredictProjectilePathResult PredictProjectilePathResult2;
	// 		Gameplay::Blueprint_PredictProjectilePath_Advanced(PredictProjectilePathParams, PredictProjectilePathResult2);
	// 		if (PredictProjectilePathResult2.PathData.Num() > 1)
	// 		{
	// 			for (int j = 1; j < PredictProjectilePathResult2.PathData.Num() - 1; j++)
	// 			{
	// 				FTransform transform2 = FTransform::Identity;
	// 				transform2.SetLocation(PredictProjectilePathResult2.PathData[j].Location);
	// 				transform2.SetScale3D(FVector(0.15f));
	// 				PredictLine.AddInstance(transform2);
	// 			}
	// 		}
	// 	}
	// }
};