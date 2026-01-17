function VanillaCombo()
    
    gData = {}
    
    gData.FRAMEWORKS = {}
    gData.RUNNING_ATTACKS = {}
    gData.STRAFING = {}
    gData.COMBOS = {}

    gData.FRAMEWORKS.STRAFE_FLAGS = {
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


    gData.FRAMEWORKS.PlayerMove = function()
        SENS = 0.08
        c = 0
        
        return SENS < GetStickValue(16, c) or GetStickValue(16, c) < -SENS or SENS < GetStickValue(17, c) or GetStickValue(17, c) < -SENS
    end
    
    gData.FRAMEWORKS.ReturnStyles = function()
        return PedIsPlaying(gPlayer, "/Global/Player/Default_KEY", true) or PedIsPlaying(gPlayer, "/Global/GS_Male_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/StrafeIdle", true) or PedIsPlaying(gPlayer, "/Global/GS_Male_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/CombatBasic", true)
    end
    
    gData.FRAMEWORKS.SetAction = function(NODE, ROOT)
        if PedIsPlaying(gPlayer, NODE, true) then
            return false
        else
            PedSetActionNode(gPlayer, NODE, ROOT)
            return true
        end
    end
    
    gData.FRAMEWORKS.ReturnButtons = function()
        for BUTTONS = 0, 15 do
            if IsButtonPressed(BUTTONS, 0) then 
                return true 
            end
        end
        return false
    end
    
    gData.COMBOS.Combo_1 = function()
        if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks/Left1/Release/HeavyAttacks", true) then
            Wait(200)
            PedOverrideStat(gPlayer, 8, 100)
		    PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Defense/Evade/EvadeRight/HeavyAttacks/EvadeLeftPunch", "act/anim/BOSS_Darby.act")
        elseif PedIsPlaying(gPlayer, "/Global/BOSS_Darby/Defense/Evade/EvadeRight/HeavyAttacks/EvadeLeftPunch", true) and IsButtonPressed(6, 0) then
            PedSetActionNode(gPlayer, "/Global/G_Striker/Offense/Short/Strikes/HeavyAttacks/HeavyKnee", "act/anim/G_Striker.act")
        end
    end
        
    gData.COMBOS.Combo_2 = function()
        if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks/Left1/Right2/Release/Unblockable/LegKickReleaseMax", true) then
            Wait(450)
            PedSetActionNode(gPlayer, "/Global/G_Striker/Offense/GroundAttack/GroundPunch", "Act/Anim/G_Striker.act")
        elseif PedIsPlaying(gPlayer, "/Global/G_Striker/Offense/GroundAttack/GroundPunch", true) and IsButtonPressed(6, 0) then
            PedSetActionNode(gPlayer, "/Global/Aqua/Defense/Evade/EvadeBack", "act/anim/Aqua.act")
        end
    end
        
    gData.COMBOS.Combo_3 = function()
        if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks/Left1/Right2/Left3/Release/Unblockable/JackieKick", true) then
            Wait(300)
            PedSetActionNode(gPlayer, "/Global/Actions/Offense/RunningAttacks/RunningAttacksDirect", "Globals/GlobalActions.act")
        elseif PedIsPlaying(gPlayer, "/Global/Actions/Offense/RunningAttacks/RunningAttacksDirect", true) and IsButtonPressed(6, 0) then
            PedSetActionNode(gPlayer, "/Global/BOSS_Darby/Offense/Short/Grapples/HeavyAttacks/Catch_Throw", "act/anim/BOSS_Darby.act")
        end
    end
        
    gData.COMBOS.Combo_4 = function()
        if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks/Left1/Right2/Left3/Right4/Release/Unblockable/HighKick2", true) then 
            Wait(340)
            PedSetActionNode(gPlayer, "/Global/Player/Attacks/GroundAttacks/GroundAttacks/Strikes/HeavyAttacks/GroundKick", "Act/Anim/Player.act")
        end
    end
        
    gData.COMBOS.Combo_5 = function()
        if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks/Left1/Right2/Left3/Right4/Left5/Release/Unblockable", true) and IsButtonPressed(6, 0) then
            PedSetActionNode(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks/Left1/Right2/Release/Unblockable/LegKickReleaseMax", "Act/Anim/Player.act")
        end
    end
    
    gData.COMBOS.Style_1 = function()
        if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/RunningAttacks/HeavyAttacks/RunShoulder", true) and gData.FRAMEWORKS.PlayerMove() and PedHasWeapon(gPlayer,-1) then
		    PedSetActionNode(gPlayer, "/Global/G_Ranged_A/Offense/Medium/Strikes/HeavyAttacks/HeavyKnee", "Act/Anim/G_Ranged_A.act")
		    Wait(200)
		    PedSetActionNode(gPlayer, "/Global/Nemesis/Offense/Medium/Strikes/HeavyAttacks/JackieKick", "act/anim/Nemesis.act")
        end
    end

    gData.COMBOS.Style_2 = function()
	    if IsButtonPressed(7, 0) and PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and PedIsInCombat(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and not PedIsDead(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) then
		    PedOverrideStat(gPlayer, 8, 100)
		    PedSetActionNode(gPlayer, "/Global/P_Bif/Defense/Evade/EvadeDuck", "Act/Anim/P_Bif.act")
	    	Wait(200)
	    	PedOverrideStat(gPlayer, 8, 100)
		    PedSetActionNode(gPlayer, "/Global/P_Bif/Defense/Evade/EvadeDuck/HeavyAttacks/EvadeDuckPunch", "Act/Anim/P_Bif.act")
	    end
    end
    
    gData.COMBOS.Style_3 = function()
	    if IsButtonPressed(0, 0) and PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and not PedIsDead(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) then 
		    TextPrintString("", 2, 1)
		    PedOverrideStat(gPlayer, 8, 100)
		    PedSetActionNode(gPlayer, "/Global/P_Bif/Defense/Evade/EvadeLeft/HeavyAttacks/EvadeRightPunch", "Act/Anim/P_Bif.act")
	    elseif IsButtonPressed(1, 0) and PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and not PedIsDead(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) then 
	    	TextPrintString("", 2, 1)
		    PedOverrideStat(gPlayer, 8, 100)
		    PedSetActionNode(gPlayer, "/Global/P_Bif/Defense/Evade/EvadeRight/HeavyAttacks/EvadeLeftPunch", "Act/Anim/P_Bif.act")
	    end
    end
	
	gData.COMBOS.Style_4 = function()
	    if IsButtonPressed(3,0) and PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and PedIsInCombat(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and not PedIsDead(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and PedHasWeapon(gPlayer, -1) and not PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/Hold_Idle", true) then
		    local a, b = {
        	    {"/Global/G_John/Offense/Medium/Strikes/HeavyAttack/HeavyKick", "act/anim/G_John.act"},
			    {"/Global/BOSS_Darby/Offense/Short/Grapples/HeavyAttacks/Catch_Throw", "act/anim/BOSS_Darby.act"}
            }, math.random(1, 2)
            PedSetActionNode(gPlayer, a[b][1],a[b][2])
	    elseif PedIsPlaying(gPlayer, "/Global/G_John/Offense/Medium/Strikes/HeavyAttack/HeavyKick", true) and IsButtonPressed(6, 0) then
		    PedSetActionNode(gPlayer, "/Global/Player/Attacks/Strikes/LightAttacks/Left1/Right2/Release/Unblockable/LegKickReleaseMax", "act/anim/Player.act")
	    end
    end
    
    gData.COMBOS.Style_5 = function()
        if PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/Hold_Idle", true) then 
            if IsButtonPressed(3, 0) then
                local c, d = {
				    {"/Global/G_John/Offense/Special/SpecialActions/Grapples/Dash", "act/anim/G_John.act"}, 
				    {"/Global/Actions/Grapples/GrappleReversals", "Globals/GlobalActions.act"},
				    {"/Global/Actions/Grapples/Front/Grapples/GrappleOpps/Melee/Greaser/GrabKnees/GV", "Globals/G_Melee_A.act"}
			    }, math.random(1, 3)
			    PedSetActionNode(gPlayer, c[d][1], c[d][2])
		    end
        end
    end
    
    gData.COMBOS.Block = function()
        if PedIsPlaying(gPlayer, "/Global/HitTree/Standing/Melee", true) and not PedIsHit(gPlayer, true) and PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET2()) and PedIsInCombat(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET2()) and not PedIsDead(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET2()) and not PedMePlaying(gPlayer, "Front_Float") and not PedMePlaying(gPlayer, "On_Ground") and not PedMePlaying(gPlayer, "OnGroundBounce") and not PedMePlaying(gPlayer, "DownOnGround") and not PedMePlaying(gPlayer, "GroundAndWallHits") and not PedMePlaying(gPlayer, "KOReactions") and not PedMePlaying(gPlayer, "PlayerOnGround") and not PedMePlaying(gPlayer, "BellyUp") and not PedMePlaying(gPlayer, "BellyDown") then
		    PedSetDamageGivenMultiplier(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET(), 2, 0)
		    PedSetActionNode(gPlayer, "/Global/Actions/Defence/Block/Block/BlockHits/HitsLight", "Globals/GlobalActions.act")
        end
    end
    
    gData.COMBOS.Block_2 = function()
        if PedIsHit(gPlayer, true) and PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and PedIsInCombat(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and PedGetWhoHitMeLast() ~= gPlayer then
		    return PedSetActionNode(gPlayer, "/Global/Actions/Defence/Block/Block/BlockHits/HitsLight", "Globals/GlobalActions.act")
	    end
    end
    
    gData.RUNNING_ATTACKS.FlyingKick = function()
        if PedIsPlaying(gPlayer, "/Global/Player/Attacks/Strikes/RunningAttacks/HeavyAttacks/RunShoulder", true) and gData.FRAMEWORKS.PlayerMove() and PedHasWeapon(gPlayer,-1) then
            PedSetActionNode(gPlayer, "/Global/G_Ranged_A/Offense/Medium/Strikes/HeavyAttacks/HeavyKnee", "Act/Anim/G_Ranged_A.act")
            Wait(200)
            PedSetActionNode(gPlayer, "/Global/Nemesis/Offense/Medium/Strikes/HeavyAttacks/JackieKick", "act/anim/Nemesis.act")
        end
    end
    
    gData.STRAFING.PlayerStrafing = function()
        if PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and PedIsInCombat(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and not PedIsDead(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) and PedHasWeapon(gPlayer, -1) and gData.FRAMEWORKS.ReturnStyles() and not gData.FRAMEWORKS.ReturnButtons() and not PedIsHit(gPlayer) then
            local L_STICK = math.abs(GetStickValue(16, 0)) + math.abs(GetStickValue(17, 0))
            
            if L_STICK >= gData.FRAMEWORKS.STRAFE_FLAGS.SENSIVITY then
                gData.FRAMEWORKS.SetAction("/Global/GS_Male_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/CombatBasic", "Act/Anim/GS_Male_A.act")
            else
                gData.FRAMEWORKS.SetAction("/Global/GS_Male_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/StrafeIdle", "Act/Anim/GS_Male_A.act")
            end
            
            local L_X, L_Y, L_Z = PedGetPosXYZ(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET())
            
            PedFaceXYZ(gPlayer, L_X, L_Y, L_Z)
        elseif (not PedIsValid(gData.FRAMEWORKS.STRAFE_FLAGS.GET_TARGET()) or gData.FRAMEWORKS.ReturnButtons()) and (PedIsPlaying(gPlayer, "/Global/GS_Male_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/CombatBasic", true) or PedIsPlaying(gPlayer, "/Global/GS_Male_A/Default_KEY/ExecuteNodes/LocomotionOverride/Combat/StrafeIdle", true)) then
            PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
        end
    end
    
    cSuper = gData.COMBOS
    cMovements = gData.STRAFING
    
    gData.INIT = function()
        for _, ComboAttacks in pairs(cSuper) do
            ComboAttacks()
        end
    
        for _, StrafingPlayer in pairs(cMovements) do
            StrafingPlayer()
        end
    end
end

VanillaCombo()
VanillaCombo = nil

collectgarbage()

function main()
    while not SystemIsReady() or AreaIsLoading() do
        Wait(400)
    end
    
    LoadAllAnim()
    while true do
        
        Wait(0)
        gData.RUNNING_ATTACKS.FlyingKick()
        gData.INIT()
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
    LoadAnimationGroup("JohnnyCheer")
    LoadAnimationGroup("LE_Orderly")
    LoadAnimationGroup("Nemesis")
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
    local tReturnPlayerInfo = PlayerGetPunishmentPoints() + GetSkippingPunishment()
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
    local tInit = math.random(1, 2)
end
 
F_UpdateTimeCycle = function()
    if not IsMissionCompleated("1_B") then
        local tNow = GetCurrentDay(false)
        if tNow < 0 or tNow > 2 then
            SetCurrentDay(0)
        end
    end
    F_UpdateCurfew()
end
 
F_UpdateCurfew = function()
    local tTime = shared.gCurfewRules
    if not tTime then
        tTime = F_CurfewDefaultRules
    end
    tTime()
end
 
F_CurfewDefaultRules = function()
    local tTimeN = ClockGet()
    if tTimeN >= 23 or tTimeN < 7 then
        shared.gCurfew = true
    else
        shared.gCurfew = false
    end
end