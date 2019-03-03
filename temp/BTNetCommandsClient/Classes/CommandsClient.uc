class CommandsClient extends Mutator;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientConsoleCommand;
}

simulated function PostNetBeginPlay() {

	local PlayerPawn PP;

	PP = PlayerPawn(Owner);

	PP.Say("[CommandsClient] Spawned on the client");

}

simulated function ClientConsoleCommand(Pawn P, string CommandString) {
	PlayerPawn(Owner).Say("[CommandsClient] Executing console command on client: " $ CommandString);
	Pawn(Owner).ConsoleCommand(CommandString);
}