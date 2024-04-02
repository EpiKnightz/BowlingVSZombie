class UResponsesComponent : UActorComponent
{
	TSet<USnippet> SnippetList;

	UFUNCTION()
	USnippet Get(TSubclassOf<USnippet> iSnippetClass)
	{
		for (USnippet Snippet : SnippetList)
		{
			if (Snippet.IsA(iSnippetClass))
			{
				return Snippet;
			}
		}
		return nullptr;
	}
};