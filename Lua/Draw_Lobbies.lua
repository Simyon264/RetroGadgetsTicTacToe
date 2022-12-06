local Lobbies = {}

local vars = require("Vars.lua")
local wifiChip: Wifi = gdt.Wifi0
local VidChip: VideoChip = gdt.VideoChip0
local json = require("json.lua")
local font = gdt.ROM.System.Assets["StandardFont"]

function Lobbies.Draw()
if #vars.lobbyList == 0 then
         VidChip:DrawText(vec2(12, VidChip.Height / 2), font, "NO LOBBIES FOUND", color.red, color.black)
         vars.blinkButton()
         if gdt.LedButton0.ButtonDown == true and vars.didFetch == true then
            vars.state = "menu"
            vars.lobbyId = ""
         end
         return
      end

      canInput = false
      if vars.lastChange == 0 then
         canInput = true
      end
      vars.lastChange = math.abs(gdt.DPad0.X) + math.abs(gdt.DPad0.Y)

      if canInput == true then
         if vars.currentlySelectedIngame == 10 then
            if gdt.DPad0.X > 0 then
               vars.currentlySelectedIngame = 7
               canInput = false
            end
         end
      end

      newSelect = vars.currentSelectedLobby
      VidChip:DrawRect(vec2(40, 5), vec2(220, 60), color.green)
      VidChip:DrawRect(vec2(19, 5), vec2(220, 60), color.green)
      if vars.currentSelectedLobby == 1 then
         VidChip:FillRect(vec2(20,6), vec2(39,15), color.gray)
         VidChip:DrawText(vec2(20, 6), font, "JOIN", color.green, color.gray)
         if canInput == true then
            if gdt.DPad0.Y < 0 then newSelect = 2 end
         end
      else
         VidChip:DrawText(vec2(20, 6), font, "JOIN", color.green, color.black)
      end
      VidChip:DrawLine(vec2(19, 15), vec2(40, 15), color.green)
      if vars.currentSelectedLobby == 2 then
         VidChip:FillRect(vec2(20, 16), vec2(39,24), color.gray)
         VidChip:DrawText(vec2(20, 16), font, "BACK", color.red, color.gray)
         if canInput == true then
            if gdt.DPad0.Y < 0 then newSelect = 3 end
            if gdt.DPad0.Y > 0 then newSelect = 1 end
         end
         vars.blinkButton()
         if gdt.LedButton0.ButtonDown == true then
            vars.lobbyId = ""
            vars.state = "menu"
         end
      else
         VidChip:DrawText(vec2(20, 16), font, "BACK", color.red, color.black)
      end
      VidChip:DrawLine(vec2(19, 25), vec2(40, 25), color.green)
      if vars.currentSelectedLobby == 3 then
         VidChip:FillRect(vec2(20, 26), vec2(39,44), color.gray)
         VidChip:DrawText(vec2(20, 26), font, "NEXT", color.green, color.gray)
         if canInput == true then
            if gdt.DPad0.Y > 0 then newSelect = 2 end
            if gdt.DPad0.Y < 0 then newSelect = 4 end
         end
         if vars.currentlySelectedLobbyInList + 1 < #vars.lobbyList + 1 then
            vars.blinkButton()
            if gdt.LedButton0.ButtonDown == true then
               vars.currentlySelectedLobbyInList += 1
            end
         end
      else
         VidChip:DrawText(vec2(20, 26), font, "NEXT", color.green, color.black)
      end
      VidChip:DrawLine(vec2(19, 45), vec2(40, 45), color.green)
      if vars.currentSelectedLobby == 4 then
         VidChip:FillRect(vec2(20, 46), vec2(39, 59), color.gray)
         VidChip:DrawText(vec2(20, 46), font, "PREV", color.green, color.gray)
         if canInput == true then
            if gdt.DPad0.Y > 0 then newSelect = 3 end
            if vars.currentlySelectedLobbyInList - 1 ~= 0 then
               vars.blinkButton()
               if gdt.LedButton0.ButtonDown == true then
                  vars.currentlySelectedLobbyInList -= 1
               end
            end
         end
      else
         VidChip:DrawText(vec2(20, 46), font, "PREV", color.green, color.black)
      end
      vars.currentSelectedLobby = newSelect

      -- Show lobby information
      -- Check if lobby is nil
      if vars.lobbyList[vars.currentlySelectedLobbyInList] == nil then
         vars.currentlySelectedLobbyInList = 1
      end

      currentLobby = vars.lobbyList[vars.currentlySelectedLobbyInList]
      VidChip:DrawText(vec2(42, 7), font, "Name: " .. currentLobby.name, color.green, color.black)

      playerDisplay = "1/2"
      playersColor = color.green

      if currentLobby.playerO ~= nil then
         playerDisplay = "2/2"
         playersColor = color.red
      end

      VidChip:DrawText(vec2(42, 15), font, "Players: " .. playerDisplay, playersColor, color.black)
      if vars.currentSelectedLobby == 1 then
         if playerDisplay ~= "2/2" then
            vars.blinkButton()
            if gdt.LedButton0.ButtonDown == true then
               data = json.encode({GameVersion=vars.version, clientId=vars.uuid, lobbyId=currentLobby.uuid})
               wifiChip:WebPostData(vars.url .. "/lobby/join", data)
               vars.isHost = false
            end
         end
      end
end

return Lobbies