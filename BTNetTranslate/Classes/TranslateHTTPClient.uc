class TranslateHTTPClient extends UBrowserHTTPClient;

event HTTPReceivedData(string Data) {

	Log("[BTNetTranslate] HTTPReceivedData: " $ Data);

	if (len(Data) > 0) {

		// If message is for the sender client only...
		if (Left(Data, 8) == "[CLIENT]") {
			// Don't broadcast it to everyone
			PlayerPawn(Owner).ClientMessage(class'BTNetTranslate.Translator'.static.colorMsg("[BT.Net] " $ Mid(Data, 9), "white"));
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

