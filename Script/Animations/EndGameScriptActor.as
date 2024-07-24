class AEndGameScriptActor : ALevelScriptActor
{
	FVoidEvent EOnSequenceFinished;

	UFUNCTION(BlueprintCallable, Category = "Script Actor")
	void OnSequenceFinished(){};
};