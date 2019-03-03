class TranslateHTTPClient extends UBrowserHTTPClient;

var BTNetTranslator ParentTranslator;
var CommandsClient ClientExecuter;

event HTTPReceivedData(string Data) {

	Log("[BTNetTranslate] HTTPReceivedData: " $ Data);

	if (len(Data) > 0) {

		// If message is for the sender client only...
		if (Left(Data, 8) == "[CLIENT]") {
			// Don't broadcast it to everyone
			PlayerPawn(Owner).ClientMessage(class'BTNetTranslate.BTNetTranslator'.static.colorMsg("[BT.Net] " $ Mid(Data, 9), "white"));
		} else if (Left(Data, 9) == "[CONSOLE]") {
			// Console command to be executed by the player
			// Pawn(Owner).ConsoleCommand(Mid(Data, 10));

			if (Role == ROLE_Authority) {
				Log("[BTNetTranslate] Executing console command using ClientExecuter");
				ClientExecuter = ParentTranslator.ClientExecuter;
				ClientExecuter.ClientConsoleCommand(Mid(Data, 10));
			}

		} else {
			// Normal message; broadcast publicly
			PlayerPawn(Owner).Say(Data);
		}
		
	}

}

event HTTPError(int Code) {
	Log("[BTNetTranslate] HTTPError: " $ String(Code));
	PlayerPawn(Owner).ClientMessage("Translation error: " $ Code);
}