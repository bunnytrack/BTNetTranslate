class BTNetTranslateSpawnNotify expands SpawnNotify;

simulated function PreBeginPlay()
{
	bAlwaysRelevant = True;
}

simulated event Actor SpawnNotification(Actor A)
{
	if (A.IsA('PlayerPawn')) {
		Spawn(Class'BTNetTranslate.CommandsClient', A);
	}
	return A;
}

defaultproperties
{
}