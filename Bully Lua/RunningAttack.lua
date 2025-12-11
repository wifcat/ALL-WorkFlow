--[[
Running attack replacement by aqxua
]]

RunningAttack = function()
	local function IsMoving()
    local st = 0.08
	    return st < GetStickValue(16, c) or GetStickValue(16, c) < -st or st < GetStickValue(17, c) or GetStickValue(17, c) < -st
	end
	while true do
		Wait(0)
		-- Check if Jimmy running headbutt or no:
		if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/RunningAttacks/HeavyAttacks/RunShoulder", true) and IsMoving() and PedHasWeapon(gPlayer,-1) then
			PedSetAITree(gPlayer, "/Global/DarbyAI", "Act/AI/AI_DARBY_2_B.act")
			PedSetActionNode(gPlayer, "/Global/Actions/Offense/RunningAttacks/RunningAttacksDirect", "Globals/GlobalActions.act")
			PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
		end
	end
end