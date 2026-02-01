--[[
## A simple Strafing framework and mod for Bully Scripting, not written in oop, modular, and all that ##
## Compile using my Lua Compiler Apk ##
## Enjoy the custom strafing system :) ##
## Don't forget to load anim group ##
]]

STRAFE_STANCE = {}
STRAFE_STANCE.FRAMEWORK = {}
STRAFE_STANCE.STRAFING = {}

Framework = gData.FRAMEWORK
Strafes = gData.STRAFING

Framework.PlayerMove = function()
    SENS = 0.08
    c = 0
    
    return SENS < GetStickValue(16, c) or GetStickValue(16, c) < -SENS or SENS < GetStickValue(17, c) or GetStickValue(17, c) < -SENS
end

Framework.ReturnStyles = function()
    return PedIsPlaying(gPlayer, "/Global/Player/Default_KEY", true) or PedIsPlaying(gPlayer, "StrafeIdle", true) or PedIsPlaying(gPlayer, "CombatBasic", true)
end

Framework.SetAction = function(NODE, ROOT)
    if PedIsPlaying(gPlayer, NODE, true) then
        return false
    else
        PedSetActionNode(gPlayer, NODE, ROOT)
        return true
    end
end

Framework.ReturnButtons = function()
    for BUTTONS = 0, 15 do
        if IsButtonPressed(BUTTONS, 0) then 
            return true 
        end
    end
    return false
end

STRAFE_STANCE.FRAMEWORK.STRAFE_FLAGS = {
    SENSIVITY = 0.1,
        
    GET_TARGET = function()
        return PedGetTargetPed(gPlayer)
    end,
    
    GET_COORD = function()
        return PedGetPosXYZ(gPlayer)
    end,
        
    GET_TARGET2 = function()
        return PedGetTargetPed()
    end,
}

Strafes.PlayerStrafing = function()
    if PedIsValid(Framework.STRAFE_FLAGS.GET_TARGET()) and PedIsInCombat(Framework.STRAFE_FLAGS.GET_TARGET()) and not PedIsDead(Framework.STRAFE_FLAGS.GET_TARGET()) and PedHasWeapon(gPlayer, -1) and Framework.ReturnStyles() and not Framework.ReturnButtons() and not PedIsHit(gPlayer) then
        local L_STICK = math.abs(GetStickValue(16, 0)) + math.abs(GetStickValue(17, 0))
        
        if L_STICK >= Framework.STRAFE_FLAGS.SENSIVITY then
            Framework.SetAction("CombatBasic", "act")
        else
            Framework.SetAction("StrafeIdle", "act")
        end
        
        local L_X, L_Y, L_Z = PedGetPosXYZ(Framework.STRAFE_FLAGS.GET_TARGET())
        PedFaceXYZ(gPlayer, L_X, L_Y, L_Z)
    elseif (not PedIsValid(Framework.STRAFE_FLAGS.GET_TARGET()) or Framework.ReturnButtons()) and (PedIsPlaying(gPlayer, "CombatBasic", true) or PedIsPlaying(gPlayer, "StrafeIdle", true)) then
        PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
    end
end

-- Call:
--function main()
--	Strafes.PlayerStrafing()
--end
