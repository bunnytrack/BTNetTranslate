class CommandsClient extends Actor;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientConsoleCommand;
}

simulated function ClientConsoleCommand(string CommandString) {
	// if (Role != ROLE_Authority) {
		Log("[CommandsClient] Executing console command: " $ CommandString);
		PlayerPawn(Owner).Say("[CommandsClient] Executing console command: " $ CommandString);
		Pawn(Owner).ConsoleCommand(CommandString);
	// }
}

