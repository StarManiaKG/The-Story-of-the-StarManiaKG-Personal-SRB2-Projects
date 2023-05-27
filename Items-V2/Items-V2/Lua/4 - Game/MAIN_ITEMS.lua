--// VARIABLES
-- Links
local IV2 = itemslibV2;

local IV2C = IV2.Core;
local IV2CI = IV2C.Items;
local IV2I = IV2.Inputs;

--// HOOKS
addHook("PlayerThink", function(player)
	if (player.mo and player.mo.valid)
		-- Grabbing Items
		if not (IV2CI.Grabbed)
			IV2C.currentItem = IV2CI.FindItem(player.mo);
			if (IV2C.currentItem) print(IV2C.currentItem); end
			
			if (IV2I[GC_CUSTOM1].press and IV2C.currentItem)
				IV2CI.Grabbed = true;
				return;
			end
		end
		
		-- Running Item Actions
		if (IV2CI.Grabbed) IV2CI.RunItemActions(IV2CI[IV2C.currentItem.type], player.mo); end
	end
end)