--[[
Random mechanics by aqxua

]]


-- Here's the swap model template
	if PedIsModel(gPlayer, 0) then
		-- Use Player's fighting style 
		PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act"
    	PlayerSwapModel("GRGirl_Lola") -- Note: You can find all ped's model name in aqxua.txt
    	PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
    end

	-- Here's a swipe down mod template when Player is grabbing npc:
	if PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/Hold_Idle", true) and IsButtonPressed(15,0) then 
		PedSetActionNode(gPlayer, "/Global/Actions/Grapples/Front/Grapples/GrappleMoves/Adult_Takedown/Give", "act/anim/CV_Male_A.act")
	end

	-- Replace Jimmy's Ground kick template:
	if PedIsPlaying(gPlayer, "/Global/Player/Attacks/GroundAttacks/GroundAttacks/Strikes/HeavyAttacks/GroundKick", "Act/Anim/Player.act") then
		PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Special/Throw","act/anim/BOSS_Darby.act")
    end