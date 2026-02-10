--[[ 

unfinished
]]


ThrowMolotov = function()
	while true do
	    Wait(0)
	    if PedIsModel(gPlayer, 0) then
			GiveWeaponToPlayer(420, 1)
	        if PedHasWeapon(gPlayer, 420) then
	            if IsButtonPressed(6, 0) then
					PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
					
					-- Increase player's anim speed? (dk, not worked):
					GameSetPedStat(gPlayer, 20, 205)
		            PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Special/Throw","act/anim/BOSS_Darby.act")
					Wait(40)
					GameSetPedStat(gPlayer, 20, 100)
					
					PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
					local Target = PedGetTargetPed(gPlayer)
					if PedIsValid(Target) then
						for i = 1, 30 do
							Wait(0)
							if PedIsHit(Target, true) then
								-- Cower (worked unconditionally):
								PedSetTaskNode(Target, "/Global/AI/Ally/AllyFearAction/AllyCower", "Act/AI/AI.act")
								
								-- Target screams when get hit:
								SoundStopCurrentSpeechEvent(Target)
								SoundPlayAmbientSpeechEvent(Target, "FLEE")
								
								-- Apply damage:
								PedApplyDamage(Target, 70)
								
								-- Fire effect:
								local ex, ye, zet = PedGetPosXYZ(Target)
								local Effect = EffectCreate("GymFire", ex, ye, zet)
								
								-- Effect stay on Target for 1.9s long
								EffectSlowKill(Effect, 1.9)
								PedFlee(Target)
							end 
						end 
					end 
	            end 
	        end
	    end
	end 
end 
