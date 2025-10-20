--[[
Note: Some of codes are not mine, i uses them to enhances this mod
Originally, This is a walking style mod by Ad Pangestu
]]


function main()
    while not SystemIsReady() or AreaIsLoading() do
        Wait(0)
    end
    -- FLAGS SETUP
    LoadAnim()
    SoundLoadBank("MISSION\\1_B.bnk")
    SoundLoadBank("MISSION\\3_05.bnk")
    TutorialShowMessage("P_Striker_A Darby",5000, true)
    sensitivity = 0.1
    Style = "P_Striker_A"
    moving = false
    strafing = false
    timesSprintPressed = 0
    timer = 0
    lastTimeSprintPressed = GetTimer()
    lastTimeRunning = GetTimer()
    PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
    PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
    while Alive do
      Wait(0)
      CreateThread("F_Model")
    end
end

-- REQUIRED FUNCTION SETUP
function PlayerSetActionNode(node, file)
  if PedIsPlaying(gPlayer, node, true) then
    return false
  else
    PedSetActionNode(gPlayer, node, file)
    return true
  end
end

function PlayerIsFree()
  return PedIsPlaying(gPlayer, "/Global/Player/Default_KEY", true) or PlayerIsFreeStyle()
end

function PlayerIsFreeStyle()
  return PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY", true) or PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/WalkBasic", true) or PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/RunBasic", true) or PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/SprintBasic", true)
end

function PlayerIsStrafing()
  return PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/StrafeIdle", true) or PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/CombatBasic", true)
end


function IsAnyButtonPressed(c)
  do
    for i = 0, 15 do
      if IsButtonPressed(i, 0) then
        return true
      end
    end
  end
  return false
end
--
function F_Block()
	if PedIsPlaying(gPlayer, "/Global/HitTree/Standing/Melee", true) and PedIsValid(PedGetTargetPed()) and PedIsInCombat(PedGetTargetPed()) and not PedIsDead(PedGetTargetPed()) and not PedMePlaying(gPlayer, "Front_Float") and not PedMePlaying(gPlayer, "On_Ground") and not PedMePlaying(gPlayer, "OnGroundBounce") and not PedMePlaying(gPlayer, "DownOnGround") and not PedMePlaying(gPlayer, "GroundAndWallHits") and not PedMePlaying(gPlayer, "KOReactions") and not PedMePlaying(gPlayer, "PlayerOnGround") and not PedMePlaying(gPlayer, "BellyUp") and not PedMePlaying(gPlayer, "BellyDown")  then
		PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Defense/Block/Block/BlockHits/HitsLight", "act/anim/BOSS_Darby.act")
	end
    Wait(0)
end

function L_HitTree()
	for NPC,ped in {PedFindInAreaXYZ(0, 0, 0, 99999)} do
      if PedIsPlaying(gPlayer, "/Global/Aqua/Offense/Short/Strikes/LightAttacks", true) and not PedIsPlaying(gPlayer, "/Global/Aqua/Offense/Short/Strikes/LightAttacks/JAB", true) and PedGetWhoHitMeLast(ped) == gPlayer then
        if PedIsPlaying(ped, "/Global/HitTree/Standing/Melee/Generic/Straight/HEADJAB", true) then
          PedSetActionNode(ped, "/Global/HitTree/Standing/Melee/Unique/SACKED/Front", "act/anim/HitTree.act")
  	    PedSetHealth(ped, PedGetHealth(ped) + 10 * PedGetDamageGivenMultiplier(gPlayer, 2))
  	    Wait(0)
  		SoundStopCurrentSpeechEvent(ped)
  	  end
      end
    end
    Wait(0)
end

function F_Model()
	if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks", "Act/Anim/Player.act") and PedHasWeapon(gPlayer, -1) then
		PedSetAITree(gPlayer, "/Global/DarbyAI", "Act/AI_DARBY_2_B.act")
		PedSetActionNode(gPlayer, "/Global/Aqua/Offense/Short/Strikes/LightAttacks", "act/anim/Aqua.act")
	while PedIsPlaying(gPlayer, "/Global/Aqua/Offense/Short/Strikes/LightAttacks", true) do
        Wait(0)
	end
	PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
	end
    Wait(0)
  -- additions
	Target = PedGetTargetPed(gPlayer)
    if IsButtonPressed(15, 0) and PedIsValid(Target) and PedIsInCombat(Target) and not PedIsDead(Target) and PedHasWeapon(gPlayer, -1) then
        local a, b = {
        {"/Global/Aqua/Defense/Evade/EvadeCounter", "act/anim/Aqua.act"},
		{"/Global/Aqua/Defense/Evade/EvadeBack", "act/anim/Aqua.act"}
      }, math.random(1,2)
      PedSetAITree(gPlayer, "/Global/DarbyAI", "Act/AI/AI_DARBY_2_B.act")
      PedSetActionNode(gPlayer, a[b][1],a[b][2])
      PedSetAITree(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
    end
  -- fix run
  if not PlayerIsInAnyVehicle() and PedHasWeapon(gPlayer, -1) then
      if Style ~= "Player" then
        if IsButtonBeingPressed(7, 0) then
          timesSprintPressed = timesSprintPressed + 1
          lastTimeSprintPressed = GetTimer()
        elseif GetTimer() >= lastTimeSprintPressed + 400 then
          timesSprintPressed = 0
        end
        if IsButtonBeingReleased(7, 0) then
          lastTimeRunning = GetTimer()
        end
        local target = PedGetTargetPed(gPlayer)
        if PedIsValid(target) and PedIsInCombat(target) and not PedIsDead(target) and (PlayerIsFree() or PlayerIsStrafing()) then
          strafing = true
          if sensitivity <= math.abs(GetStickValue(16, 0)) + math.abs(GetStickValue(17, 0)) then
            PlayerSetActionNode("/Global/P_Striker_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/CombatBasic", "Act/Anim/P_Striker_A.act")
          else
            PlayerSetActionNode("/Global/P_Striker_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/StrafeIdle", "Act/Anim/P_Striker_A.act")
          end
          local x, y, z = PedGetPosXYZ(target)
          PedFaceXYZ(gPlayer, x, y, z)
        elseif strafing and not PedIsValid(target) and PlayerIsStrafing() then
          strafing = false
          PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
        end
        if PlayerIsFree() and PedGetFlag(gPlayer, 2) ~= true then
          if sensitivity <= math.abs(GetStickValue(16, 0)) + math.abs(GetStickValue(17, 0)) then
            moving = true
            if timesSprintPressed > 1 then
              PlayerSetActionNode("/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/SprintBasic", "Act/Anim/P_Striker_A.act")
            elseif IsButtonPressed(7, 0) or GetTimer() < lastTimeRunning + 200 then
              PlayerSetActionNode("/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/RunBasic", "Act/Anim/P_Striker_A.act")
            else
              PlayerSetActionNode("/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/WalkBasic", "Act/Anim/P_Striker_A.act")
            end
          elseif moving then
            moving = false
            PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
          end
        end
        if (IsButtonBeingPressed(6, 0) or IsButtonBeingPressed(8, 0) or IsButtonBeingPressed(7, 0) and PedIsValid(PedGetTargetPed(gPlayer))) and (PlayerIsFreeStyle() or PlayerIsStrafing()) and not PedIsValid(PedGetGrappleTargetPed(gPlayer)) then
          if IsButtonBeingPressed(6, 0) and (IsButtonPressed(7, 0) or timesSprintPressed > 1) then
            PedSetActionNode(gPlayer, "/Global/Actions/Offense/RunningAttacks/RunningAttacksDirect", "Globals/GlobalActions.act")
          else
            PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
          end
        end
      end
      if IsButtonPressed(9, 0) and not PedIsValid(PedGetGrappleTargetPed(gPlayer)) and 1 >= DistanceBetweenPeds2D(PedGetTargetPed(gPlayer), gPlayer) then
      	PedSetActionNode(gPlayer, "/Global/Player/Attacks/Grapples/Grapples/GrappleAttempt/GrappleAttempt", "Act/Anim/Player.act")
      end
      F_Block()
      F_Other()
      M_Speechs()
      L_HitTree()
    end
    Wait(0)
  if PedIsModel(gPlayer, 0) then -- swap
    PlayerSwapModel("PRlead_Darby")
  end
  if PedIsPlaying(gPlayer, "/Global/Player/Attacks/GroundAttacks/GroundAttacks/Strikes/HeavyAttacks/GroundKick", "Act/Anim/Player.act") then
	PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Special/Throw","act/anim/BOSS_Darby.act")
  end
  if PedIsPlaying(gPlayer, "/Global/Player/Default_KEY", true) and PedMePlaying(gPlayer, "Idle", true) and not PedIsValid(PedGetTargetPed()) then
    PedSetActionTree(gPlayer, "/Global/P_Striker_A", "Act/Anim/P_Striker_A.act")
  elseif PedMePlaying(gPlayer, "P_Striker_A", true) and IsAnyButtonPressed() then
    PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
    PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
  end
end

function F_Other()
  if not PedIsValid(PedGetTargetPed()) and PedMePlaying(gPlayer, "Default_KEY") and IsButtonBeingPressed(15, 0) then
    PedSetActionNode(gPlayer, "/Global/Ambient/Sitting_Down/SitHigh", "Act/Anim/Ambient.act")
  elseif PedIsPlaying(gPlayer, "/Global/Ambient/Sitting_Down/SitHigh", true) and IsButtonBeingPressed(8, 0) then
    PlayerStopAllActionControllers()
  end
  --[[
  if IsButtonBeingPressed(3, 0) then
    PedSetActionNode(gPlayer, "/Global/2_S04/Anim/BullyWall_Smoke", "Act/Conv/2_S04.act")
    PedOverrideStat(gPlayer, 5, 100)
    Wait(20000)
    PedSetActionNode(gPlayer, "/Global/2_S04/Anim/BullyWall_Smoke/EndingSequences/StepAwayEnd", "Act/Conv/2_S04.act")
  elseif PedIsPlaying(gPlayer, "/Global/2_S04/Anim/BullyWall_Smoke", true) and IsButtonBeingPressed(8, 0) then
    PlayerStopAllActionControllers()
  end
  ]]
  if IsButtonBeingPressed(8, 0) and PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/RunBasic", true) then
    PedSetActionNode(gPlayer, "/Global/Player/JumpActions/Jump", "Act/Anim/Player.act")
  elseif IsButtonBeingPressed(8, 0) and PedIsPlaying(gPlayer, "/Global/P_Striker_A/Default_KEY/ExecuteNodes/Free/SprintBasic", true) then
    PedSetActionNode(gPlayer, "/Global/Player/JumpActions/Jump", "Act/Anim/Player.act")
  end
  if IsButtonBeingPressed(15, 0) and PedIsSocializing(PedGetTargetPed(gPlayer)) and not PedIsInCombat(PedGetTargetPed(gPlayer)) then
    SoundPlayAmbientSpeechEvent(gPlayer, "Laugh", 2, "small")
    SoundPlayAmbientSpeechEvent(gPlayer, "PLAYER_LAUGH_CRUEL", 2, "small")
    PedSetActionNode(gPlayer, "/Global/Player/Social_Speech/Taunts", "Act/Player.act")
    PedSetActionNode(gPlayer, "/Global/Ambient/Reactions/HumiliationReact/Laughing/Guy_Laugh", "Act/Anim/Ambient.act")
  end
  if PedIsValid(PedGetTargetPed()) and IsButtonPressed(15, 0) and PedMePlaying(gPlayer, "Default_KEY") then
    PedSetActionNode(gPlayer, "/Global/Ambient/HarassMoves/HarassShort/Trip", "Act/Anim/Ambient.act")
  end
  if IsButtonBeingPressed(15, 0) and not PedIsInCombat(PedGetTargetPed(gPlayer)) and not PedIsDead(PedGetTargetPed(gPlayer)) and 1 >= DistanceBetweenPeds2D(PedGetTargetPed(gPlayer), gPlayer) and (PedMePlaying(PedGetTargetPed(gPlayer), "Default_KEY") or PedIsPlaying(PedGetTargetPed(gPlayer), "/Global/Ambient", true)) then
    PedSetActionNode(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt", "Act/Player.act")
    Wait(0)
    PedSetActionNode(gPlayer, "/Global/Ambient/SocialAnims/SocialHumiliateAttack/AnimLoadTrigger", "Act/Anim/Ambient.act")
    SoundPlayAmbientSpeechEvent(gPlayer, "JEER")
  end
  if SoundSpeechPlaying(gPlayer, "PLAYER_MAKE_OUT") then
    SoundStopCurrentSpeechEvent(gPlayer)
    SoundPlayAmbientSpeechEvent(gPlayer, "PLAYER_JEER")
  end
end
-- This is the humiliation code
function M_Speechs()
  if PedMePlaying(gPlayer, "Default_KEY") and IsButtonPressed(7, 0) and PedIsValid(PedGetTargetPed(gPlayer)) and not PedIsInCombat(PedGetTargetPed(gPlayer)) and not PedIsDead(PedGetTargetPed(gPlayer)) then
    SoundPlayAmbientSpeechEvent(gPlayer, "GREET")
  end
  if PedMePlaying(gPlayer, "Default_KEY") and IsButtonPressed(8, 0) and PedIsValid(PedGetTargetPed(gPlayer)) and PedIsInCombat(PedGetTargetPed(gPlayer)) and not PedIsDead(PedGetTargetPed(gPlayer)) then
    SoundPlayAmbientSpeechEvent(gPlayer, "FIGHTING")
  end
  if PedMePlaying(gPlayer, "Default_KEY") and IsButtonPressed(8, 0) and PedIsValid(PedGetTargetPed(gPlayer)) and not PedIsInCombat(PedGetTargetPed(gPlayer)) and not PedIsDead(PedGetTargetPed(gPlayer)) then
    PedSetActionNode(gPlayer, "/Global/Player/Social_Speech/Taunts", "Act/Player.act")
    PedSetActionNode(gPlayer, "/Global/Ambient/SocialAnims/SocialBringItOn/BullyAngry/B_TAUNT_A", "Act/Anim/Ambient.act")
    SoundPlayAmbientSpeechEvent(gPlayer, "TAUNT")
  end
  if PedMePlaying(gPlayer, "Default_key") and PedIsValid(PedGetTargetPed()) and PedIsDead(PedGetTargetPed()) and IsButtonPressed(8, 0) then
    SoundPlayAmbientSpeechEvent(gPlayer, math.random(1, 2) == 1 and "VICTORY_INDIVIDUAL" or "BOISTEROUS")
    PedSetActionNode(gPlayer, "/Global/4_05/NIS/Jimmy/Jimmy_Pool", "Act/Conv/4_05.act")
  end
end
-- ends here
F_AttendedClass = function()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return 
  end
  SetSkippedClass(false)
  PlayerSetPunishmentPoints(0)
end
 
F_MissedClass = function()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return 
  end
  SetSkippedClass(true)
  StatAddToInt(166)
end
 
F_AttendedCurfew = function()
  if not PedInConversation(gPlayer) and not MissionActive() then
    TextPrintString("You got home in time for curfew", 4)
  end
end
 
F_MissedCurfew = function()
  if not PedInConversation(gPlayer) and not MissionActive() then
    TextPrint("TM_TIRED5", 4, 2)
  end
end
 
F_StartClass = function()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return 
  end
  F_RingSchoolBell()
  local l_6_0 = PlayerGetPunishmentPoints() + GetSkippingPunishment()
end
 
F_EndClass = function()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return 
  end
  F_RingSchoolBell()
end
 
F_StartMorning = function()
  F_UpdateTimeCycle()
end
 
F_EndMorning = function()
  F_UpdateTimeCycle()
end
 
F_StartLunch = function()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    F_UpdateTimeCycle()
    return 
  end
  F_UpdateTimeCycle()
end
 
F_EndLunch = function()
  F_UpdateTimeCycle()
end
 
F_StartAfternoon = function()
  F_UpdateTimeCycle()
end
 
F_EndAfternoon = function()
  F_UpdateTimeCycle()
end
 
F_StartEvening = function()
  F_UpdateTimeCycle()
end
 
F_EndEvening = function()
  F_UpdateTimeCycle()
end
 
F_StartCurfew_SlightlyTired = function()
  F_UpdateTimeCycle()
end
 
F_StartCurfew_Tired = function()
  F_UpdateTimeCycle()
end
 
F_StartCurfew_MoreTired = function()
  F_UpdateTimeCycle()
end
 
F_StartCurfew_TooTired = function()
  F_UpdateTimeCycle()
end
 
F_EndCurfew_TooTired = function()
  F_UpdateTimeCycle()
end
 
F_EndTired = function()
  F_UpdateTimeCycle()
end
 
F_Nothing = function()
end
 
F_ClassWarning = function()
  if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
    return 
  end
  local l_23_0 = math.random(1, 2)
end
 
F_UpdateTimeCycle = function()
  if not IsMissionCompleated("1_B") then
    local l_24_0 = GetCurrentDay(false)
    if l_24_0 < 0 or l_24_0 > 2 then
      SetCurrentDay(0)
    end
  end
  F_UpdateCurfew()
end
 
F_UpdateCurfew = function()
  local l_25_0 = shared.gCurfewRules
  if not l_25_0 then
    l_25_0 = F_CurfewDefaultRules
  end
  l_25_0()
end
 
F_CurfewDefaultRules = function()
  local l_26_0 = ClockGet()
  if l_26_0 >= 23 or l_26_0 < 7 then
    shared.gCurfew = true
  else
    shared.gCurfew = false
  end
end

LoadAnim = function()
    if groups == nil then
    groups = {
      "3_04WrongPtTown",
      "4_04_FunhouseFun",
      "Authority",
      "BBALL_21",
      "Boxing",
      "B_Striker",
      "CV_Female",
      "CV_Male",
      "C_Wrestling",
      "DodgeBall",
      "DO_Edgar",
      "DO_Grap",
      "DO_StrikeCombo",
      "DO_Striker",
      "Earnest",
      "F_Adult",
      "F_BULLY",
      "F_Crazy",
      "F_Douts",
      "F_Girls",
      "F_Greas",
      "F_Jocks",
      "F_Nerds",
      "F_OldPeds",
      "F_Pref",
      "F_Preps",
      "G_Grappler",
      "G_Johnny",
      "G_Striker",
      "Grap",
      "Hang_Workout",
      "J_Damon",
      "J_Grappler",
      "J_Melee",
      "J_Ranged",
      "J_Striker",
      "KissAdult",
      "LE_Orderly",
      "MINIHACKY",
      "Nemesis",
      "NIS_6_02",
      "NPC_Mascot",
      "N_Ranged",
      "N_Striker",
      "N_Striker_A",
      "N_Striker_B",
      "NIS_6_03",
      "P_Grappler",
      "P_Striker",
      "POI_Smoking",
      "PunchBag",
      "Qped",
      "Rat_Ped",
      "Russell",
      "Russell_Pbomb",
      "Straf_Dout",
      "Straf_Fat",
      "Straf_Female",
      "Straf_Male",
      "Straf_Nerd",
      "Straf_Prep",
      "Straf_Savage",
      "Straf_Wrest",
      "TE_Female",
      "V_Bike",
      "W_PooBag"
    }
  end
  for _, i in ipairs(groups) do
    LoadAnimationGroup(i)
  end
end