local wifiChip: Wifi = gdt.Wifi0
local VidChip: VideoChip = gdt.VideoChip0

local json = require("json.lua")
local vars = require("Vars.lua")

local utils = require("utils.lua")
local Draw_Menu = require("Draw_Menu.lua")
local Draw_Ingame = require("Draw_Ingame.lua")
local Draw_Lobbies = require("Draw_Lobbies.lua")

local font = gdt.ROM.System.Assets["StandardFont"]

print("Using json.lua version " .. json._version)
print("Gadget version: " .. vars.version)

function heartbeat()
   vars.lastHeartbeat += 1
   if vars.lastHeartbeat > 60 then
      vars.latestHeartbeat += 1
      vars.lastHeartbeat = 0
   end
   if vars.latestHeartbeat == 1 then
      vars.latestHeartbeat = 0
      data = json.encode({GameVersion=vars.version, clientId=vars.uuid})
      wifiChip:WebPostData(vars.url .. "/heartbeat", data)
   end
end

-- lobby heartbeat. Also gives lobby data.lastLobbyBeat = 0latestLobbyBeat = 0
function lobbyHeartbeat()
   vars.lastLobbyBeat += 1
   if vars.lastLobbyBeat > 30 then
      vars.latestLobbyBeat += 1
      vars.lastLobbyBeat = 0
   end
   if vars.latestLobbyBeat == 1 then
      vars.latestLobbyBeat = 0
      data = json.encode({GameVersion=vars.version, clientId=vars.uuid, lobbyId=vars.lobbyId})
      wifiChip:WebPostData(vars.url .. "/lobbyheartbeat", data)
   end
end

function update()
   gdt.LedButton0.LedState = false
   if wifiChip.AccessDenied then
      vars.state = "accessDenied"
   elseif vars.connected == true then
      heartbeat()
      if vars.state ~= "premenu" then
         if vars.lobbyId ~= "" then
            if vars.lobbyId ~= "-1" then
               lobbyHeartbeat()
            else
               if vars.lastUpdate == 0 then
                  vars.lastUpdate = 30
                  wifiChip:WebGet(vars.url .. "/lobbies")
               end
               vars.lastUpdate -= 1
            end
         end

         if vars.lobbyId == "" then
            vars.blinkButton()
            if vars.state ~= "lobbies" then vars.state = "menu" end
            if gdt.DPad0.Y > 0 then
               if vars.currentlySelected == 2 then
                  vars.currentlySelected -= 1
               end
            elseif gdt.DPad0.Y < 0 then
               if vars.currentlySelected == 1 then
                  vars.currentlySelected += 1
               end
            end
            if gdt.LedButton0.ButtonDown == true then
               if vars.currentlySelected == 2 then
                  data = json.encode({GameVersion=vars.version, clientId=vars.uuid})
                  wifiChip:WebPostData(vars.url .. "/lobby", data)
                  vars.isHost = true
               else
                  vars.state = "lobbies"
                  vars.lobbyId = "-1"
                  vars.didFetch = false
                  vars.currentSelectedLobby = 1
                  vars.lastUpdate = 30
                  vars.currentlySelectedLobbyInList = 1
                  vars.lobbyList = {}
               end
            end
         elseif vars.state == "lobby" then
            vars.blinkButton()
            if gdt.LedButton0.ButtonDown == true then
               vars.lobbyId = ""
               vars.state = "menu"
            end
            if vars.lobbyInformation ~= nil then
               if vars.lobbyInformation.playerO ~= nil then
                  vars.state = "ingame"
               end
            end
         end
      elseif vars.state == "premenu" then
         if string.len(vars.name) > 0 then
            vars.blinkButton()
            if gdt.LedButton0.ButtonDown then
               data = json.encode({GameVersion=vars.version, clientId=vars.uuid, newName=vars.name})
               wifiChip:WebPostData(vars.url .. "/client", data)
            end
         end
      end
   else
      vars.connected = false
      if vars.tries < 3 then
         vars.state = "connecting"
      else
         vars.blinkButton()
         if gdt.LedButton0.ButtonDown == true then
            vars.tries = 0
         end
      end
   end
      VidChip:Clear(color.black)
   if vars.state == "accessDenied" then
      VidChip:DrawText(vec2(20, VidChip.Height / 2), font, "NO ACCESS TO WIFI", color.red, color.black)
   elseif vars.state == "connecting" then
      VidChip:DrawText(vec2(8, VidChip.Height / 2), font, "CONNECTING TO SERVER...", color.white, color.black)
      if not vars.isConnecting then
         data = json.encode({GameVersion=vars.version})
         wifiChip:WebPostData(vars.url .. "/connect", data)
         vars.isConnecting = true
      end
   elseif vars.state == "error" then
      VidChip:DrawText(vec2(20, VidChip.Height / 2), font, "COULD NOT CONNECT", color.red, color.black)
   elseif vars.state == "418" then
      VidChip:DrawText(vec2(10, VidChip.Height / 2), font, "GAME OUT OF DATE (418)", color.red, color.black)
   elseif vars.state == "noclient" then
      VidChip:DrawText(vec2(17, VidChip.Height / 2), font, "LOST CONNECTION (403)", color.red, color.black)
   elseif vars.state == "premenu" then
      VidChip:DrawText(vec2(17, 10), font, "NAME? (Use Keyboard)", color.green, color.black)
      VidChip:DrawRect(vec2(16, 20), vec2(116, 35), color.green)
      VidChip:DrawText(vec2(17, 22), font, vars.name, color.white, color.black)
   elseif vars.state == "menu" then
      Draw_Menu.Draw()
   elseif vars.state == "lobby" then
      VidChip:DrawText(vec2(22, 10), font, "WAITING FOR ENEMY", color.green, color.black)
      VidChip:DrawText(vec2(14, 20), font, "PRESS BUTTON TO LEAVE", color.green, color.black)
   elseif vars.state == "ingame" then
      Draw_Ingame.Draw()
   elseif vars.state == "lobbies" then
      Draw_Lobbies.Draw()
   end
end

function eventChannel2(sender: KeyboardChip, arg:KeyboardChipEvent)
   if vars.state ~= "premenu" then
      return
   end

   if arg.ButtonDown ~= true then
      return
   end

   isValid = false
   letter = arg.InputName
   if letter == "A" or letter == "B" or letter == "C" or letter == "D" or letter == "E" or letter == "F" or letter == "G" or letter == "H" or letter == "I" or letter == "J" or letter == "K" or letter == "L" or letter == "M" or letter == "N" or letter == "O" or letter == "P" or letter == "Q" or letter == "R" or letter == "S" or letter == "T" or letter == "U" or letter == "V" or letter == "W" or letter == "X" or letter == "Y" or letter == "Z" then
      isValid = true
   end
   if string.len(vars.name) == 10 then
      isValid = false
   end
   if isValid == true then
      vars.name = vars.name .. letter
   end
   if letter == "Backspace" then
      vars.name = vars.name:sub(1, -2)
   end
end

function eventChannel1(sender: Wifi, arg: WifiWebResponseEvent)
   if arg.IsError then
      print("MSG: " .. arg.ErrorMessage)
      vars.connected = false
      vars.isConnecting = false
      if arg.ResponseCode == 418 then
         vars.uuid = ""
         vars.tries = 1000
         vars.state = "418"
         return
      elseif arg.ResponseCode == 403 then
         vars.tries = 1000
         vars.state = "noclient"
         vars.uuid = ""
         return
      elseif arg.ResponseCode== 400 then
         vars.state = "lobbies"
         vars.lobbyInformation = {}
         vars.lobbyId = ""
         vars.connected = true
         return
      end
      vars.tries += 1
      if vars.tries > 2 then
         vars.state = "error"
      else
         vars.state = "connecting"
      end
      return
   end

   --print(arg.Text)
   data = json.decode(arg.Text)
   type = data.type
   if type == "connection" then
      vars.lobbyId = ""
      vars.uuid = data.uuid
      vars.state = "premenu"
      vars.isConnecting = false
      vars.connected = true
   elseif type == "heartbeat" then
      --print("Recieved heartbeat!")
   elseif type == "lobby" then
      print("Lobby created!")
      vars.lobbyId = data.lobbyId
      vars.state = "lobby"
   elseif type == "lobbyHeartbeat" then
      vars.lobbyInformation = {
         lobbyId = data.lobbyId,
         board = data.board,
         playerX = data.playerX,
         playerO = data.playerO,
         turn = data.turn,
         winner = data.winner
      }
   elseif type == "name" then
      vars.state = "menu"
   elseif type == "space" then
      -- yes
   elseif type == "lobbies" then
      vars.lobbyList = {}
      vars.lobbyList = data.lobbies
      vars.didFetch = true
   else
      print("UNKOWN DATA TYPE: " .. type)
   end
   --print("CODE: " .. arg.ResponseCode)
end