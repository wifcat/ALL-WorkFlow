function M_Speechs()
  -- Greet
  if PedMePlaying(gPlayer, "Default_KEY") and IsButtonPressed(7, 0) and PedIsValid(PedGetTargetPed(gPlayer)) and not PedIsInCombat(PedGetTargetPed(gPlayer)) and not PedIsDead(PedGetTargetPed(gPlayer)) then
    SoundPlayAmbientSpeechEvent(gPlayer, "GREET")
  end
  -- Fight Taunts
  if PedMePlaying(gPlayer, "Default_KEY") and IsButtonPressed(8, 0) and PedIsValid(PedGetTargetPed(gPlayer)) and PedIsInCombat(PedGetTargetPed(gPlayer)) and not PedIsDead(PedGetTargetPed(gPlayer)) then
    SoundPlayAmbientSpeechEvent(gPlayer, "FIGHTING")
  end
  -- Insults
  if PedMePlaying(gPlayer, "Default_KEY") and IsButtonPressed(8, 0) and PedIsValid(PedGetTargetPed(gPlayer)) and not PedIsInCombat(PedGetTargetPed(gPlayer)) and not PedIsDead(PedGetTargetPed(gPlayer)) then
    PedSetActionNode(gPlayer, "/Global/Player/Social_Speech/Taunts", "Act/Player.act")
    PedSetActionNode(gPlayer, "/Global/Ambient/SocialAnims/SocialBringItOn/BullyAngry/B_TAUNT_A", "Act/Anim/Ambient.act")
    SoundPlayAmbientSpeechEvent(gPlayer, "TAUNT")
  end
  -- Victorious taunt
  if PedMePlaying(gPlayer, "Default_key") and PedIsValid(PedGetTargetPed()) and PedIsDead(PedGetTargetPed()) and IsButtonPressed(8, 0) then
    SoundPlayAmbientSpeechEvent(gPlayer, math.random(1, 2) == 1 and "VICTORY_INDIVIDUAL" or "BOISTEROUS")
    PedSetActionNode(gPlayer, "/Global/4_05/NIS/Jimmy/Jimmy_Pool", "Act/Conv/4_05.act")
  end
end
