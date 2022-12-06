local vars = {}

vars.state = "connecting" -- system state, used to determine what to do. See the state table below for more information
-- state table:
-- connecting: the gadget is trying to connect to the server
-- error: the gadget failed to connect to the server
-- accessDenied: the gadget is not allowed to connect to the server
-- premenu: the gadget is waiting for the player to enter a name
-- menu: the gadget is waiting for the player to select an option
-- lobbies: the gadget is waiting for the player to select a lobby
-- lobby: the gadget is waiting for another player to start the game
-- ingame: the gadget is playing the game.
-- 418: the client is out of date
-- noclient: client tried to call an endpoint but is not allowed, ussuallly because the client ID it has is not accepted by the server.

vars.font = gdt.ROM.System.Assets["StandardFont"]

vars.connected = false
vars.isConnecting = false
vars.tries = 0 -- If this is 3 or more, the gadget will go into the error state

vars.version = "1.0.0"

-- Player Information
vars.uuid = ""
vars.name = ""

-- Server information
port = 3000
IP = "127.0.0.1"
vars.url = string.format("http://%s:%d", IP, port)
vars.lobbyId = ""
vars.lobbyInformation = nil
vars.isHost = false

-- menu stuff
vars.currentlySelected = 1
vars.currentlySelectedIngame = 1
vars.lastChange = 0

-- button logic
buttonBlink = 30

-- heartbeat logic
vars.lastHeartbeat = 0
vars.latestHeartbeat = 0
vars.lastLobbyBeat = 0
vars.latestLobbyBeat = 0

-- lobby list updater
vars.lobbyList = {}
vars.lastUpdate = 30
vars.currentSelectedLobby = 1
vars.didFetch = false
vars.currentlySelectedLobbyInList = 1

function vars.blinkButton()
   buttonBlink -= 1
   if buttonBlink < 0 then
      gdt.LedButton0.LedState = false
   else
      gdt.LedButton0.LedState = true
   end
   if buttonBlink < -30 then
      buttonBlink = 30
   end
end

return vars