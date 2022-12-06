local Menu = {}

local vars = require("Vars.lua")
local wifiChip: Wifi = gdt.Wifi0
local VidChip: VideoChip = gdt.VideoChip0
local json = require("json.lua")
local font = gdt.ROM.System.Assets["StandardFont"]

function Menu.Draw()
    VidChip:DrawText(vec2(5, VidChip.Height - 7), font, "V." .. vars.version, color.green, color.black)
    VidChip:DrawText(vec2(5, 20), font, "TicTacToe", color.green, color.black)
    VidChip:DrawRect(vec2(70, 10), vec2(220, 50), color.green)
    VidChip:DrawRect(vec2(70, 10), vec2(220, 30), color.green)
    if vars.currentlySelected == 1 then
        VidChip:FillRect(vec2(70, 10), vec2(220, 30), color.green)
        VidChip:DrawText(vec2(76, 16), font, "Find Game", color.black, color.green)
        VidChip:DrawText(vec2(72, 36), font, "Create Game", color.green, color.black)
    else
        VidChip:FillRect(vec2(70, 30), vec2(220,50), color.green)
        VidChip:DrawText(vec2(76, 16), font, "Find Game", color.green, color.black)
        VidChip:DrawText(vec2(72, 36), font, "Create Game", color.black, color.green)
    end
end

return Menu