--[[
This is a simple mod where we can toggle on/off Clock.
Written by aqxua
Compile this using Lua Compiler: https://youtu.be/eO64awFgCCA?si=ELumzuniQ29d4hcE
Discord server: https://discord.gg/ffAVKNYxwd
]]

function main()
	while true do
		Wait(0)
		V_ClockOrganiser()
	end
end

local ClockPaused = false

function V_ClockOrganiser()
    Wait(0)
    if PedIsModel(gPlayer, 0) then
		GiveWeaponToPlayer(420, 1)
        if PedHasWeapon(gPlayer, 420) then
            if IsButtonPressed(6, 0) then
                if not ClockPaused then
                	TutorialShowMessage("Clock Paused",900,true)
                    PauseGameClock()
                    ClockPaused = true
                else
                	TutorialShowMessage("Clock Continued",900,true)
                    UnpauseGameClock()
                    ClockPaused = false
                end
            end
        end
    end
end
