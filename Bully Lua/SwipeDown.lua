--[[
A simple Swipe Down code, by aqxua
]]

SwipeDown = function()
	while true do
		Wait(0)
		-- This is a simple swipe down mod:
		if IsButtonPressed(15,0) then
			PedSetAITree(gPlayer, "/Global/DarbyAI", "Act/AI/AI_DARBY_2_B.act")
			-- NODE HERE:
			PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Special/Throw","act/anim/BOSS_Darby.act")
			PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
		end
	end
end

RandomSwipeDown = function()
	while true do
		Wait(0)
		-- Optional, make a variable 'Target' so swipe down only work when only aiming
		local Target = PedGetTargetPed(gPlayer)
		-- You can copy and paste this `if' statement method for the SwipeDown() function too so it only work while aiming!
	    if IsButtonPressed(15, 0) and PedIsValid(Target) and PedIsInCombat(Target) and not PedIsDead(Target) and PedHasWeapon(gPlayer, -1) then
	        local a, b = { -- 2 Tables: a = Nodes, b = math.random()
	        {"/Global/Aqua/Defense/Evade/EvadeCounter", "act/anim/Aqua.act"},
			{"/Global/Aqua/Defense/Evade/EvadeBack", "act/anim/Aqua.act"}
	      }, math.random(1,2) -- Parameter 2 is a how much probability the nodes will play
	      PedSetAITree(gPlayer, "/Global/DarbyAI", "Act/AI/AI_DARBY_2_B.act")
	      PedSetActionNode(gPlayer, a[b][1],a[b][2]) -- Here's how you set the Actions 
	      PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
	    end
	end
end