--[[

AUTO EVADE TEMPLATE, BY AD PANGESTU

]]

function main()
	Wait(500)
	LoadAllAnim()
	CreateThread("F_Auto_Evade")
  -- F_Auto_Evade()
	repeat
	   Wait(0)
	until not Alive
end

F_Auto_Evade = function()
	while true do
    -- a table of settings
		local pedattack,target,dist,evade_freq = {
			{"/Global/Nemesis/Offense"},
			{"/Global/Nemesis/Special"},
			{"/Global/B_Striker_A/Offense"},
			{"/Global/1_03_Davis/Offense"},
			{"/Global/BOSS_Russell/Offense"},
			{"/Global/BOSS_Russell/Special"},
			{"/Global/Russell_102/Offense"},
			{"/Global/P_Striker_A/Offense"},
			{"/Global/2_07_Gord/Offense"},
			{"/Global/P_Striker_B/Offense"},
			{"/Global/P_Grappler_A/Offense"},
			{"/Global/P_Bif/Offense"},
			{"/Global/P_Bif/Special"},
			{"/Global/BOSS_Darby/Offense"},
			{"/Global/BOSS_Darby/Special"},
			{"/Global/G_Striker_A/Offense"},
			{"/Global/G_Melee_A/Offense"},
			{"/Global/G_Grappler_A/Offense"},
			{"/Global/G_Ranged_A/Offense"},
			{"/Global/G_Johnny/Offense"},
			{"/Global/G_Johnny/Special"},
			{"/Global/Norton/Offense"},
			{"/Global/N_Striker_A/Offense"},
			{"/Global/N_Striker_B/Offense"},
			{"/Global/N_Ranged_A/Offense"},
			{"/Global/N_Earnest/Offense"},
			{"/Global/J_Striker_A/Offense"},
			{"/Global/J_Melee_A/Offense"},
			{"/Global/J_Grappler_A/Offense"},
			{"/Global/J_Ted/Offense"},
			{"/Global/J_Mascot/Offense"},
			{"/Global/J_Mascot/Special"},
			{"/Global/DO_Striker_A/Offense"},
			{"/Global/DO_Grappler_A/Offense"},
			{"/Global/DO_Edgar/Offense"},
			{"/Global/Crazy_Basic/Offense"},
			{"/Global/CV_Male_A/Offense"},
			{"/Global/CV_Female_A/Offense"},
			{"/Global/CV_OLD/Offense"},
			{"/Global/CV_Drunk/Offense"},
			{"/Global/GS_Fat_A/Offense"},
			{"/Global/GS_Male_A/Offense"},
			{"/Global/GS_Female_A/Offense"},
		},PedGetTargetPed(gPlayer),3,1000
		
		local ped_is_attack = function()
			for i = 1,table.getn(pedattack) do
				if PedIsPlaying(PedGetTargetPed(gPlayer),pedattack[i][1],true) then
					return true
				end
			end
			return false
		end
		
		local x,y,z = PedGetPosXYZ(gPlayer)
		local tx,ty,tz = PedGetPosXYZ(target)
		
		if PedIsValid(target) and PedGetTargetPed(target) == gPlayer then
	       if PedMePlaying(gPlayer,"DEFAULT_KEY") or PedIsPlaying(gPlayer,"/Global/HitTree",true) then
		      if ped_is_attack() then
		         if math.abs(x - tx) + math.abs(y - ty) + math.abs(z - tz) <= dist and math.random(1,1000) < evade_freq then
				    local Evades,Random = {
                  -- if you want to add some nodes, add in here, example:
                  -- (Johnny's Running throat grap)
                  -- {"/Global/G_Johnny/Offense/Special/SpecialActions/Grapples/Dash", "act/anim/G_Johnny.act"}, 
			            {"/Global/P_Bif/Defense/Evade/EvadeDuck", "act/anim/P_Bif.act"}
				    }, math.random(1,1) -- and then the math.random(parameter1, parameter2 << change it on how much you add the nodes)
				    PedSetAITree(gPlayer,"/Global/AI","Act/AI.act")
			        PedSetActionNode(gPlayer,Evades[Random][1],Evades[Random][2]) -- this doesn't need to be edited.
				    PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
					end
				end
			end
		end
		Wait(0)
	end
end

 function LoadAllAnim()
  LoadAnimationGroup("Authority")
  LoadAnimationGroup("Boxing")
  LoadAnimationGroup("B_Striker")
  LoadAnimationGroup("CV_Female")
  LoadAnimationGroup("CV_Male")
  LoadAnimationGroup("DO_Edgar")
  LoadAnimationGroup("DO_Grap")
  LoadAnimationGroup("DO_StrikeCombo")
  LoadAnimationGroup("DO_Striker")
  LoadAnimationGroup("Earnest")
  LoadAnimationGroup("F_Adult")
  LoadAnimationGroup("F_BULLY")
  LoadAnimationGroup("F_Crazy")
  LoadAnimationGroup("F_Douts")
  LoadAnimationGroup("F_Girls")
  LoadAnimationGroup("F_Greas")
  LoadAnimationGroup("F_Jocks")
  LoadAnimationGroup("F_Nerds")
  LoadAnimationGroup("F_OldPeds")
  LoadAnimationGroup("F_Pref")
  LoadAnimationGroup("F_Preps")
  LoadAnimationGroup("G_Grappler")
  LoadAnimationGroup("G_Johnny")
  LoadAnimationGroup("G_Striker")
  LoadAnimationGroup("Grap")
  LoadAnimationGroup("J_Damon")
  LoadAnimationGroup("J_Grappler")
  LoadAnimationGroup("J_Melee")
  LoadAnimationGroup("J_Ranged")
  LoadAnimationGroup("J_Striker")
  LoadAnimationGroup("LE_Orderly")
  LoadAnimationGroup("Nemesis")
  LoadAnimationGroup("NPC_Mascot")
  LoadAnimationGroup("N_Ranged")
  LoadAnimationGroup("N_Striker")
  LoadAnimationGroup("N_Striker_A")
  LoadAnimationGroup("N_Striker_B")
  LoadAnimationGroup("P_Grappler")
  LoadAnimationGroup("P_Striker")
  LoadAnimationGroup("PunchBag")
  LoadAnimationGroup("Qped")
  LoadAnimationGroup("Rat_Ped")
  LoadAnimationGroup("Russell")
  LoadAnimationGroup("Russell_Pbomb")
  LoadAnimationGroup("Straf_Dout")
  LoadAnimationGroup("Straf_Fat")
  LoadAnimationGroup("Straf_Female")
  LoadAnimationGroup("Straf_Male")
  LoadAnimationGroup("Straf_Nerd")
  LoadAnimationGroup("Straf_Prep")
  LoadAnimationGroup("Straf_Savage")
  LoadAnimationGroup("Straf_Wrest")
  LoadAnimationGroup("TE_Female")
  collectgarbage()
end

function F_AttendedClass()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return
  end
  SetSkippedClass(false)
  PlayerSetPunishmentPoints(0)
end
function F_MissedClass()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return
  end
  SetSkippedClass(true)
  StatAddToInt(166)
end
function F_AttendedCurfew()
  if not PedInConversation(gPlayer) and not MissionActive() then
    TextPrintString("You got home in time for curfew", 4)
  end
end
function F_MissedCurfew()
  if not PedInConversation(gPlayer) and not MissionActive() then
    TextPrint("TM_TIRED5", 4, 2)
  end
end
function F_StartClass()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return
  end
  F_RingSchoolBell()
  local l_6_0 = PlayerGetPunishmentPoints() + GetSkippingPunishment()
end
function F_EndClass()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return
  end
  F_RingSchoolBell()
end
function F_StartMorning()
  F_UpdateTimeCycle()
end
function F_EndMorning()
  F_UpdateTimeCycle()
end
function F_StartLunch()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    F_UpdateTimeCycle()
    return
  end
  F_UpdateTimeCycle()
end
function F_EndLunch()
  F_UpdateTimeCycle()
end
function F_StartAfternoon()
  F_UpdateTimeCycle()
end
function F_EndAfternoon()
  F_UpdateTimeCycle()
end
function F_StartEvening()
  F_UpdateTimeCycle()
end
function F_EndEvening()
  F_UpdateTimeCycle()
end
function F_StartCurfew_SlightlyTired()
  F_UpdateTimeCycle()
end
function F_StartCurfew_Tired()
  F_UpdateTimeCycle()
end
function F_StartCurfew_MoreTired()
  F_UpdateTimeCycle()
end
function F_StartCurfew_TooTired()
  F_UpdateTimeCycle()
end
function F_EndCurfew_TooTired()
  F_UpdateTimeCycle()
end
function F_EndTired()
  F_UpdateTimeCycle()
end
function F_Nothing()
end
function F_ClassWarning()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return
  end
  local l_23_0 = math.random(1, 2)
end
function F_UpdateTimeCycle()
  if not IsMissionCompleated("1_B") then
    local l_24_0 = GetCurrentDay(false)
    if l_24_0 < 0 or 2 < l_24_0 then
      SetCurrentDay(0)
    end
  end
  F_UpdateCurfew()
end
function F_UpdateCurfew()
  local l_25_0 = shared.gCurfewRules
  l_25_0 = l_25_0 or F_CurfewDefaultRules
  l_25_0()
end
function F_CurfewDefaultRules()
  local l_26_0 = ClockGet()
  if 23 <= l_26_0 or l_26_0 < 7 then
    shared.gCurfew = true
  else
    shared.gCurfew = false
  end
end
