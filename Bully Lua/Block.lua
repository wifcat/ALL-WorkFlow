-- Replace Blocking
TestBlock= function()
	while true do
		Wait(0)
		local gPlayer_Target = PedGetTargetPed(gPlayer)
		if PedIsPlaying(gPlayer, "/Global/HitTree/Standing/Melee", true) 
			and PedIsValid(gPlayer_Target) and PedIsInCombat(gPlayer_Target) 
			and not PedIsDead(gPlayer_Target) and not PedMePlaying(gPlayer, "Front_Float") and not PedMePlaying(gPlayer, "On_Ground") 
			and not PedMePlaying(gPlayer, "OnGroundBounce") and not PedMePlaying(gPlayer, "DownOnGround") 
			and not PedMePlaying(gPlayer, "GroundAndWallHits") and not PedMePlaying(gPlayer, "KOReactions") and not PedMePlaying(gPlayer, "PlayerOnGround") 
			and not PedMePlaying(gPlayer, "BellyUp") and not PedMePlaying(gPlayer, "BellyDown")  then
			-- Derby Block 
			PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Defense/Block/Block/BlockHits/HitsLight", "act/anim/BOSS_Darby.act")
		end
	    Wait(0)
	end
end