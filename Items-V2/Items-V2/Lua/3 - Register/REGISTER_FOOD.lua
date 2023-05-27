--// VARIABLES
-- Links
local IV2 = itemslibV2;

local IV2C = IV2.Core;
local IV2CI = IV2C.Items;

--// FUNCTIONS
IV2CI.AddItem(MT_FLICKY_01, {
	type = "food",
	amount = 15,
	actions = {
		select = "Eat Birb",
		close = "Let it Live"
	},
	
	sharable = true
});