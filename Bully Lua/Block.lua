for i = 1, 500 do
		    if PedIsHit(gPlayer, 2) and PedIsInCombat(PedGetTargetPed(gPlayer)) then
		        PedSetActionNode(gPlayer, "/Global/Actions/Defence/Block/Block/BlockHits/HitsLight", "Globals/GlobalActions.act")
		        break
		    end
		end