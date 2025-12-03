--[[ 

A simple Souls like game Rolling Animations
Writren by aqxua
Discord server: https://discord.gg/ffAVKNYxwd
Compile this using my Lua Compiler! - https://youtu.be/eO64awFgCCA?si=po-i-mHWD85fOLM6

]]

-- PC & CONTROLLER
gDiveRoll = function()
    while true do
        Wait(0)
        if IsButtonPressed(0,0) then
            PedSetTaskNode(gPlayer, "/Global/AI/VehicleAvoidance/DiveLeftSequence/FaceDiveEntity/DiveLeft", "Act/AI/AI.act")
            while PedIsDoingTask(gPlayer, "/Global/AI/VehicleAvoidance/DiveLeftSequence/FaceDiveEntity/DiveLeft", true) do
            	-- So the rolling animation only play for 800ms
                Wait(800)
            end
            PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
        end
        if IsButtonPressed(1,0) then
            PedSetTaskNode(gPlayer, "/Global/AI/VehicleAvoidance/DiveRightSequence/FaceDiveEntity/DiveRight", "Act/AI/AI.act")
            while PedIsDoingTask(gPlayer, "/Global/AI/VehicleAvoidance/DiveRightSequence/FaceDiveEntity/DiveRight", true) do
                Wait(800)
            end
            PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
        end
    end
end

-- BULLY AE TOUCHPAD
local ROLL_LEFT = true

gDiveRoll_TOUCHPAD = function()
    while true do
        Wait(0)
        local opponent = PedGetTargetPed(gPlayer)
        if IsButtonPressed(15,0) and PedIsValid(opponent) then 
            if ROLL_LEFT then
                PedSetTaskNode(gPlayer, "/Global/AI/VehicleAvoidance/DiveLeftSequence/FaceDiveEntity/DiveLeft", "Act/AI/AI.act")
                repeat
                -- So the rolling animation only play for 800ms
                    Wait(800)
                until not PedIsDoingTask(gPlayer, "/Global/AI/VehicleAvoidance/DiveLeftSequence/FaceDiveEntity/DiveLeft", true)
            else
                PedSetTaskNode(gPlayer, "/Global/AI/VehicleAvoidance/DiveRightSequence/FaceDiveEntity/DiveRight", "Act/AI/AI.act")
                repeat
                    Wait(800)
                until not PedIsDoingTask(gPlayer, "/Global/AI/VehicleAvoidance/DiveRightSequence/FaceDiveEntity/DiveRight", true)
            end
            PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
            ROLL_LEFT = not ROLL_LEFT
        end
    end
end
