local Ingame = {}

local vars = require("Vars.lua")
local wifiChip: Wifi = gdt.Wifi0
local VidChip: VideoChip = gdt.VideoChip0
local json = require("json.lua")
local font = gdt.ROM.System.Assets["StandardFont"]

function Ingame.Draw()
      VidChip:DrawText(vec2(2, 2), font, "Enemy: ", color.green, color.black)
      if vars.lobbyInformation.playerO == nil then
        vars.state = "lobby"
        return
      end

      VidChip:DrawRect(vec2(65,2), vec2(125, 62), color.green)
      -- Vertical lines
      VidChip:DrawLine(vec2(85, 2), vec2(85, 62), color.green)
      VidChip:DrawLine(vec2(105, 2), vec2(105, 62), color.green)
      -- Horizontal lines
      VidChip:DrawLine(vec2(65, 22), vec2(125, 22), color.green)
      VidChip:DrawLine(vec2(65, 42), vec2(125, 42), color.green)

      VidChip:DrawRect(vec2(40, 42), vec2(65, 62), color.green)

      if vars.currentlySelectedIngame ~= 10 then
         VidChip:DrawText(vec2(42, 44), font, "BACK", color.red, color.black)
      else
         VidChip:FillRect(vec2(41,43), vec2(64, 61), color.gray)
         VidChip:DrawText(vec2(42, 44), font, "BACK", color.red, color.gray)
      end

      side = ""
      if vars.lobbyInformation.playerO.UUID == vars.uuid then
         side = "O"
      elseif vars.lobbyInformation.playerX.UUID == vars.uuid then
         side = "X"
      end

      if side == "O" then
         VidChip:DrawText(vec2(2, 8), font, vars.lobbyInformation.playerX.Name, color.green, color.black)
      else
         VidChip:DrawText(vec2(2, 8), font, vars.lobbyInformation.playerO.Name, color.green, color.black)
      end

      VidChip:DrawText(vec2(2, 14), font, "You are: " .. side, color.green, color.black)

      if vars.lobbyInformation.turn == "X" then
         VidChip:DrawLine(vec2(4, 22), vec2(34, 52), color.green)
         VidChip:DrawLine(vec2(4, 52), vec2(34, 22), color.green)
      elseif vars.lobbyInformation.turn == "O" then
         VidChip:DrawCircle(vec2(22, 40), 15, color.green)
      end

      -- Input cooldown
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
      if vars.currentlySelectedIngame == 10 then vars.blinkButton() end

      canPress = false
      if vars.lobbyInformation.winner ~= nil then
         VidChip:DrawText(vec2(2, 20), font, "WINNER IS " .. vars.lobbyInformation.winner .. "", color.green, color.gray)
      end

      local lastSelected = vars.currentlySelectedIngame
      -- Draw Board stuff
      for i=1,9 do
         currentBoard = vars.lobbyInformation.board[i]
         if i == 1 then
            if vars.currentlySelectedIngame == i then
               VidChip:FillRect(vec2(66,3), vec2(84, 21), color.gray)
               if canInput == true and lastSelected == vars.currentlySelectedIngame then
                  if gdt.DPad0.X > 0 then vars.currentlySelectedIngame = 2 end
                  if gdt.DPad0.Y < 0 then vars.currentlySelectedIngame = 4 end
               end
            end
            if currentBoard == "X" then
               VidChip:DrawLine(vec2(66, 3), vec2(84, 21), color.green)
               VidChip:DrawLine(vec2(66, 21), vec2(84, 3), color.green)
            elseif currentBoard == "O" then
               VidChip:DrawCircle(vec2(75, 12), 8, color.green)
            end
         elseif i == 2 then
            if vars.currentlySelectedIngame == i then
               VidChip:FillRect(vec2(86,3), vec2(104, 21), color.gray)
               if canInput == true and lastSelected == vars.currentlySelectedIngame then
                  if gdt.DPad0.X > 0 then vars.currentlySelectedIngame = 3 end
                  if gdt.DPad0.X < 0 then vars.currentlySelectedIngame = 1 end
                  if gdt.DPad0.Y < 0 then vars.currentlySelectedIngame = 5 end
               end
            end
            if currentBoard == "X" then
               VidChip:DrawLine(vec2(86, 3), vec2(104, 21), color.green)
               VidChip:DrawLine(vec2(86, 21), vec2(104, 3), color.green)
            elseif currentBoard == "O" then
               VidChip:DrawCircle(vec2(95, 12), 8, color.green)
            end
         elseif i == 3 then
            if vars.currentlySelectedIngame == i then
               VidChip:FillRect(vec2(106,3), vec2(124, 21), color.gray)
               if canInput == true and lastSelected == vars.currentlySelectedIngame then
                  if gdt.DPad0.X < 0 then vars.currentlySelectedIngame = 2 end
                  if gdt.DPad0.Y < 0 then vars.currentlySelectedIngame = 6 end
               end
            end
            if currentBoard == "X" then
               VidChip:DrawLine(vec2(106, 3), vec2(124, 21), color.green)
               VidChip:DrawLine(vec2(106, 21), vec2(124, 3), color.green)
            elseif currentBoard == "O" then
               VidChip:DrawCircle(vec2(115, 12), 8, color.green)
            end
         elseif i == 4 then
            if vars.currentlySelectedIngame == i then
               VidChip:FillRect(vec2(66, 23), vec2(84, 41), color.gray)
               if canInput == true and lastSelected == vars.currentlySelectedIngame then
                  if gdt.DPad0.X > 0 then vars.currentlySelectedIngame = 5 end
                  if gdt.DPad0.Y > 0 then vars.currentlySelectedIngame = 1 end
                  if gdt.DPad0.Y < 0 then vars.currentlySelectedIngame = 7 end
               end
            end
            if currentBoard == "X" then
               VidChip:DrawLine(vec2(66, 23), vec2(84, 41), color.green)
               VidChip:DrawLine(vec2(66, 41), vec2(84, 23), color.green)
            elseif currentBoard == "O" then
               VidChip:DrawCircle(vec2(75, 32), 8, color.green)
            end
         elseif i == 5 then
            if vars.currentlySelectedIngame == i then
                VidChip:FillRect(vec2(86,23), vec2(104, 41), color.gray)
                if canInput == true and lastSelected == vars.currentlySelectedIngame then
                    if gdt.DPad0.X > 0 then vars.currentlySelectedIngame = 6 end
                    if gdt.DPad0.X < 0 then vars.currentlySelectedIngame = 4 end
                    if gdt.DPad0.Y > 0 then vars.currentlySelectedIngame = 2 end
                    if gdt.DPad0.Y < 0 then vars.currentlySelectedIngame = 8 end
               end
            end
            if vars.lobbyInformation.winner == nil then
               if currentBoard == "X" then
                    VidChip:DrawLine(vec2(86, 23), vec2(104, 41), color.green)
                    VidChip:DrawLine(vec2(86, 41), vec2(104, 23), color.green)
               elseif currentBoard == "O" then
                    VidChip:DrawCircle(vec2(95, 32), 8, color.green)
               end
            else
                VidChip:DrawText(vec2(86, 23), font, "REMATCH", color.red, color.gray)
            end
        elseif i == 6 then
            if vars.currentlySelectedIngame == i then
                VidChip:FillRect(vec2(106,23), vec2(124, 41), color.gray)
                if canInput == true and lastSelected == vars.currentlySelectedIngame then
                    if gdt.DPad0.X < 0 then vars.currentlySelectedIngame = 5 end
                    if gdt.DPad0.Y > 0 then vars.currentlySelectedIngame = 3 end
                    if gdt.DPad0.Y < 0 then vars.currentlySelectedIngame = 9 end
               end
            end
            if currentBoard == "X" then
                VidChip:DrawLine(vec2(106, 23), vec2(124, 41), color.green)
                VidChip:DrawLine(vec2(106, 41), vec2(124, 23), color.green)
            elseif currentBoard == "O" then
                VidChip:DrawCircle(vec2(115, 32), 8, color.green)
            end
        elseif i == 7 then
            if vars.currentlySelectedIngame == i then
                VidChip:FillRect(vec2(66,43), vec2(84, 61), color.gray)
                if canInput == true and lastSelected == vars.currentlySelectedIngame then
                    if gdt.DPad0.X > 0 then vars.currentlySelectedIngame = 8 end
                    if gdt.DPad0.Y > 0 then vars.currentlySelectedIngame = 4 end
                    if gdt.DPad0.X < 0 then vars.currentlySelectedIngame = 10 end
               end
            end
            if currentBoard == "X" then
                VidChip:DrawLine(vec2(66, 43), vec2(84, 61), color.green)
                VidChip:DrawLine(vec2(66, 61), vec2(84, 43), color.green)
            elseif currentBoard == "O" then
                VidChip:DrawCircle(vec2(75, 52), 8, color.green)
            end
        elseif i == 8 then
            if vars.currentlySelectedIngame == i then
                VidChip:FillRect(vec2(86,43), vec2(104, 61), color.gray)
                if canInput == true and lastSelected == vars.currentlySelectedIngame then
                    if gdt.DPad0.X > 0 then vars.currentlySelectedIngame = 9 end
                    if gdt.DPad0.X < 0 then vars.currentlySelectedIngame = 7 end
                    if gdt.DPad0.Y > 0 then vars.currentlySelectedIngame = 5 end
                end
            end
            if currentBoard == "X" then
               VidChip:DrawLine(vec2(86, 43), vec2(104, 61), color.green)
               VidChip:DrawLine(vec2(86, 61), vec2(104, 43), color.green)
            elseif currentBoard == "O" then
               VidChip:DrawCircle(vec2(95, 52), 8, color.green)
            end
        elseif i == 9 then
            if vars.currentlySelectedIngame == i then
                VidChip:FillRect(vec2(106,43), vec2(124, 61), color.gray)
                if canInput == true and lastSelected == vars.currentlySelectedIngame then
                    if gdt.DPad0.X < 0 then vars.currentlySelectedIngame = 8 end
                    if gdt.DPad0.Y > 0 then vars.currentlySelectedIngame = 6 end
                end
            end
            if currentBoard == "X" then
               VidChip:DrawLine(vec2(106, 43), vec2(124, 61), color.green)
               VidChip:DrawLine(vec2(106, 61), vec2(124, 43), color.green)
            elseif currentBoard == "O" then
                VidChip:DrawCircle(vec2(115, 52), 8, color.green)
            end
        end
        if currentBoard == "" and vars.currentlySelectedIngame == i and side == vars.lobbyInformation.turn and vars.lobbyInformation.winner == nil then
            vars.blinkButton()
            canPress = true
        end
    end

    if canPress == true then
        if gdt.LedButton0.ButtonDown then
            if side == vars.lobbyInformation.turn and vars.lobbyInformation.winner == nil then
                data = json.encode({GameVersion=vars.version, clientId=vars.uuid, space=vars.currentlySelectedIngame, lobbyId=vars.lobbyId})
                wifiChip:WebPostData(vars.url .. "/space", data)
            end
        end
    end

    if gdt.LedButton0.ButtonDown == true and vars.currentlySelectedIngame == 5 and vars.lobbyInformation.winner == nil then
        data = json.encode({GameVersion=vars.version, clientId=vars.uuid, lobbyId=vars.lobbyId})
        wifiChip:WebPostData(vars.url .. "/rematch", data)
    end

    if vars.currentlySelectedIngame == 10 and gdt.LedButton0.ButtonDown == true then
        vars.state = "menu"
        vars.lobbyId = ""
        vars.lobbyInformation = {}
    end
end

return Ingame