--[[
A simple Basic attack code, by aqxua
]]

-- NOTE - THIS ONE IS A TEST
BasicAttackWithActionTree = function()
	while true do -- Loop
	    Wait(0) -- Wait 0 frame (Required)
	    if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks", true) and PedHasWeapon(gPlayer, -1) then
	    	PedLockTarget(gPlayer, 1)
	        PedSetAITree(gPlayer, "/Global/DarbyAI", "Act/AI/AI_DARBY_2_B.act")
	        PedSetActionTree(gPlayer, "/Global/G_Striker_A", "Act/Anim/G_Striker_A.act")
	        PedSetActionNode(gPlayer, "/Global/G_Striker_A/Offense/Short/Strikes/LightAttacks", "Act/Anim/G_Striker_A.act")
	    Wait(1500) -- A timer, 1500 = 1.5 Second
	    elseif PedMePlaying(gPlayer, "/Global/G_Striker_A", true) and not IsButtonPressed(6,0) then
	        PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
	        PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
	        PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
	    end
	end
end

BasicAttack = function()
	while true do
		Wait(0)
		-- To check if Jimmy is Punching
		-- If you only want basic attacks, just cut the node until "LightAttacks"
		if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks", true) and PedHasWeapon(gPlayer, -1) then
			PedLockTarget(gPlayer, 1)
			-- Set to Darby AI:
			PedSetAITree(gPlayer, "/Global/DarbyAI", "Act/AI/AI_DARBY_2_B.act")
			-- Replace Jimmy's Punches to:
			PedSetActionNode(gPlayer, "/Global/G_Striker_A/Offense/Short/Strikes/LightAttacks", "Act/Anim/G_Striker_A.act") -- You can always change the style
			-- Loop for G_Strikee_A's Punches
			while PedIsPlaying(gPlayer, "/Global/G_Striker_A/Offense/Short/Strikes/LightAttacks", true) do
				Wait(0)
			end
			-- Change back to Jimmy's AI:
			PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
		end
	end
end