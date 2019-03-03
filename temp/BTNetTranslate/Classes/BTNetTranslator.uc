class BTNetTranslator extends Mutator config(BTNetTranslate);

var config string MutedCommands[32];
var TranslateHTTPClient WebClient;

var CommandsClient ClientExecuter;

function PreBeginPlay() {
	Level.Game.BaseMutator.AddMutator(self);
	Level.Game.RegisterMessageMutator(Self);

	// Spawn a class which can execute console commands on the client
	if (Role == ROLE_Authority) {
		Log("[BTNetTranslate] Spawning CommandsClient");
		ClientExecuter = Spawn(class'BTNetCommandsClient.CommandsClient', Self);
	}

}

simulated event PostBeginPlay() {

	Super.PostBeginPlay();

	Log("");
	Log("+--------------------------------------------------------------------------+");
	Log("| BTNetTranslate                                                           |");
	Log("| ------------------------------------------------------------------------ |");
	Log("| Author:      Dizzy <dizzy@bunnytrack.net>                                |");
	Log("| Description: Provides an interface to a server-side translation script   |");
	Log("| Version:     2017-10-01                                                  |");
	Log("| Website:     bunnytrack.net                                              |");
	Log("| ------------------------------------------------------------------------ |");
	Log("| Released under the Creative Commons Attribution-NonCommercial-ShareAlike |");
	Log("| license. See https://creativecommons.org/licenses/by-nc-sa/4.0/          |");
	Log("+--------------------------------------------------------------------------+");

}

function bool MutatorTeamMessage(Actor                 Sender,
                                 Pawn                  Receiver,
								 PlayerReplicationInfo PRI,
								 coerce string         S,
								 name                  Type,
								 optional bool         bBeep) {

	local PlayerPawn A;
	local string paramContent;
	local string paramContentURLSafe;
	local string paramMap;
	local string paramPlayer;
	local string paramIP;
	local string paramID;
	local string requestURI;

	if (Sender.IsA('PlayerPawn')) {

		if (IsCommand(S)) {

			// PlayerPawn(Sender).ClientMessage("Command name: '" $ GetCommandName(S) $ "'");
			// PlayerPawn(Sender).ClientMessage("Command content: '" $ GetCommandContent(S) $ "'");

			paramContent        = GetCommandContent(S);
			paramContentURLSafe = ReplaceText(" ", "%20", GetCommandContent(S));
			paramMap            = GetURLMap();
			paramPlayer         = PlayerPawn(Sender).PlayerReplicationInfo.PlayerName;
			paramIP             = PlayerPawn(Sender).GetPlayerNetworkAddress();
			paramID             = String(PlayerPawn(Sender).PlayerReplicationInfo.PlayerID);

			switch GetCommandName(S) {
				case "tr":
				case "translate":

					// PlayerPawn(Sender).ClientMessage(colorMsg("[BT.Net] Translating " $ GetCommandContent(S), "white"));
					// PlayerPawn(Sender).ClientMessage(colorMsg("[BT.Net] Sending to server... " $ ReplaceText(" ", "%20", GetCommandContent(S)), "white"));

					if (Sender == Receiver) {
						// Make call to translate web service
						WebClient = Spawn(Class'TranslateHTTPClient', Sender);
						WebClient.ParentTranslator = Self;

						if (WebClient != none) {
							WebClient.Browse("bunnytrack.net","/mapvote/translate/?text=" $ paramContentURLSafe $ "&p=" $ paramPlayer $ "&ip=" $ paramIP $ "&id=" $ paramID);
						}

						// Broadcast original message to players
						foreach AllActors(Class'PlayerPawn', A) {
							A.ClientMessage(colorMsg("[Translating] " $ paramPlayer $ ": " $ S, "white"));
						}
					}

					return false;
					
				break;

				case "wiki":
				case "wikipedia":

					if (Sender == Receiver) {
						// Make call to translate web service
						WebClient = Spawn(Class'TranslateHTTPClient', Sender);

						if (WebClient != none) {
							WebClient.Browse("bunnytrack.net","/mapvote/wiki/?q=" $ paramContentURLSafe $ "&p=" $ paramPlayer $ "&ip=" $ paramIP $ "&id=" $ paramID);
						}

						// Broadcast original message to players
						foreach AllActors(Class'PlayerPawn', A) {
							A.ClientMessage(colorMsg("[Wikipedia Lookup] " $ paramPlayer $ ": " $ S, "white"));
						}
					}

					return false;
					
				break;

				// case "trash":
				// case "delete":

				// 	if (Sender == Receiver) {

				// 		if (PlayerPawn(Sender).bAdmin) {
				// 			// Make call to translate web service
				// 			WebClient = Spawn(Class'TranslateHTTPClient', Sender);

				// 			if (WebClient != none) {
				// 				WebClient.Browse("bunnytrack.net","/mapvote/rate/?r=trash&as=REMOVED_ADMIN_SECRET&m=" $ paramMap $ "&p=" $ paramPlayer $ "&ip=" $ paramIP $ "&id=" $ paramID);
				// 				PlayerPawn(Sender).ClientMessage(colorMsg("[Trash] You just marked this map (" $ paramMap $ ") as trash. Good.", "white"));
				// 			}
				// 		} else {
				// 			PlayerPawn(Sender).ClientMessage(colorMsg("[Error] Bad command or not authed.", "red"));
				// 		}
						
				// 	}

				// 	return false;
					
				// break;

				case "rate":
					if (Sender == Receiver) {

						// Make call to translate web service
						WebClient = Spawn(Class'TranslateHTTPClient', Sender);

						if (WebClient != none) {
							WebClient.Browse("bunnytrack.net","/mapvote/rate/?r=" $ paramContentURLSafe $ "&m=" $ paramMap $ "&p=" $ paramPlayer $ "&ip=" $ paramIP $ "&id=" $ paramID);
						}
						
					}
				break;

				case "cp":
				case "checkpoint":
				case "b":
				case "r":
				case "open":
				case "o":
				case "blue":
				case "red":
				case "mystart":
				case "go":
					// Excluded - do nothing
				break;

				default:
					if (Sender == Receiver) {

						// Make call to translate web service
						WebClient = Spawn(Class'TranslateHTTPClient', Sender);

						if (WebClient != none) {

							requestURI = "/mapvote/cmd/?cmdName=" $ GetCommandName(S) $ "&cmdVal=" $ paramContentURLSafe $ "&m=" $ paramMap $ "&p=" $ paramPlayer $ "&ip=" $ paramIP $ "&id=" $ paramID;

							// Use a private secret to authenticate admins only
							if (PlayerPawn(Sender).bAdmin) {
								requestURI = requestURI $ "&as=REMOVED_ADMIN_SECRET";
							}

							WebClient.Browse("bunnytrack.net", requestURI);

						}
						
					}
				break;

			}

		}

	}
	
	// Mute if in block list
	if (MuteCommand(S)) {
		return false;
	}

	// Allow other message mutators to do their job.
	if (NextMessageMutator != none) {
		return NextMessageMutator.mutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	}
	
	return true;

}

/**
 * Checks for some !command
 * @example IsCommand("!tr hello") => true
 * @example IsCommand("tr hello")  => false
 */
function bool IsCommand(string message) {

	if (Left(LTrim(message), 1) == "!") {
		return true;
	}

	return false;

}

/**
 * Returns the part of the command after the initial !
 * @example GetCommandName("!tr hello") => "tr"
 */
function string GetCommandName(string message) {

	local string trimmedMessage;

	trimmedMessage = LTrim(message);

	if (!IsCommand(trimmedMessage)) {
		return "";
	}

	return Mid(trimmedMessage, 1, InStr(trimmedMessage, " ")-1);

}

/**
 * Returns the argument(s) of the command
 * @example GetCommandContent("!tr hello")       => "hello"
 * @example GetCommandContent("!tr en:ru hello") => "en:ru hello"
 */
function string GetCommandContent(string message) {

	local string trimmedMessage;

	trimmedMessage = LTrim(message);

	if (!IsCommand(trimmedMessage)) {
		return "";
	}

	return Mid(trimmedMessage, InStr(trimmedMessage, " ")+1);

}

/**
 * Adds Nexgen message HUD color strings to the message
 */
static function string colorMsg(string message, string color) {

	// Check if Nexgen is avaible
	// if (!bNexgenEnabled()) return message;

	switch color {
		case "red": return "<C00>"$message;
		break;
		case "white": return "<C04>"$message;
		break;
		case "green": return "<C02>"$message;
		break;
		default: return message;
	}
}

static final function string LTrim(coerce string S)
{
	while (Left(S, 1) == " ")
		S = Right(S, Len(S) - 1);
	return S;
}

static final function string RTrim(coerce string S)
{
	while (Right(S, 1) == " ")
		S = Left(S, Len(S) - 1);
	return S;
}

static final function string Trim(coerce string S)
{
	return LTrim(RTrim(S));
}

static final function string ReplaceText(coerce string Search, coerce string Replacement, coerce string Subject)
{
	local int i;
	local string Output;
 
	i = InStr(Subject, Search);
	while (i != -1) {	
		Output = Output $ Left(Subject, i) $ Replacement;
		Subject = Mid(Subject, i + Len(Search));	
		i = InStr(Subject, Search);
	}
	Output = Output $ Subject;
	return Output;
}

function bool MuteCommand(String cmd) {
	local int i,k;

	for (i=0; i < ArrayCount(MutedCommands); i++)
	{
		// Check against block list
		if(MutedCommands[i] != "" && InStr(CAPS(cmd),MutedCommands[i]) != -1) {
			return true;
		}
	}

	return false;
}

function bool bNexgenEnabled() {

	local string ServerActors;

	ServerActors = CAPS(ConsoleCommand("get ini:Engine.Engine.GameEngine ServerActors"));

	if(InStr(ServerActors, "NEXGEN") != -1) {
		return true;
	}
	
	return false;
}


defaultproperties {
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	MutedCommands(0)="!TR"
	MutedCommands(1)="!TRANSLATE"
	MutedCommands(2)="!WIKI"
	MutedCommands(3)="!WIKIPEDIA"
	MutedCommands(4)="!TRASH"
	MutedCommands(4)="!DELETE"
}