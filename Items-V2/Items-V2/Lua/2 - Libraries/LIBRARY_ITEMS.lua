--// VARIABLES
-- Links
local IV2 = itemslibV2;

local IV2C = IV2.Core;
local IV2CI = IV2C.Items;
local IV2E = IV2.Environment;

--// LIBRARIES
-- ITEMS --
--[[
	function IV2CI.AddItem
		arguments:
			mobj_t *itemType;
			table_t *itemTable;

		description:
			Adds the Item Listed to the Items Table.
			
		possible returns:
			nil;
]]--
function IV2CI.AddItem(itemType, itemTable)
	if (type(itemType) ~= "number") error("Argument 1 to AddItem needs to be a Enum (I.E, MT_*)!", 2); end
	if (type(itemTable) ~= "table") error("Argument 2 to AddItem needs to be a Table!", 2); end

	IV2CI[itemType] = itemTable;
end

--[[
	function IV2CI.FindItem
		arguments:
			mobj_t *mobj;

		description:
			Return the Item Closest to the Player, if It's in the Item Table
			
		possible returns:
			mobj_t *item;
]]--
function IV2CI.FindItem(mobj)
	for item in mobj.subsector.sector.thinglist() do
		if not (item) continue; end 																-- Do We Have a Valid Object?
		if not (item.health and item ~= mobj) continue; end 										-- Does the Item Have Health, And Are We Not Part Of This Iterator?
		if not (IV2CI[item.type]) continue; end 													-- Is the Item in Our Table?

		if (item.z > (mobj.z + mobj.height)) continue; end 											-- Are We and The Item At The Right Height?
		if not (P_CheckSight(mobj, item)) continue; end 											-- Can We See The Item?
		
		local dist = FixedHypot(FixedHypot(mobj.x - item.x, mobj.y - item.y), mobj.z - item.z);
		if (dist > 6*FRACUNIT) continue; end 														-- Is the Item Among Us?
		
		return item;																				-- Return the Item Then!
	end
end

--[[
	function IV2CI.RunItemActions
		arguments:
			table_t *itemTable;
			mobj_t *mobj;

		description:
			Runs an Items' Set Actions For a Player Based on Inputs
			
		possible returns:
			nil;
]]--
function IV2CI.RunItemActions(itemTable, mobj)
	-- Create Variables --
	local player = mobj.player;

	-- Run Errors --
	if not (player) error("How do you expect us to run these actions for someone who isn't a player?", 2); end

	-- Physically Strangle the Object --
	local mox, moy, moz;
	local itemMox, itemMoy, itemMoz;
	
	if not (IV2CI.Holding)
		mox, moy, moz = mobj.momx, mobj.momy, mobj.momz;
		itemMox, itemMoy, itemMoz = item.momx, item.momy, item.momz;

		mobj.momx, mobj.momy, mobj.momz = 0, $1, $1;
		item.momx, item.momy, item.momz = 0, $1, $1;

		IV2CI.Holding = true;
	end

	IV2E.DoProperTeleportMove(item, mobj.x+2*FRACUNIT, mobj.y+2*FRACUNIT, mobj.z);

	-- Run Controls for the Object --
	-- Perform Dropping
	if (IV2I[GC_SPIN].press)
		-- Drop the Object
		IV2CI.Grabbed = false;
		IV2CI.Holding = false;

		-- Reset Momentum
		mobj.momx, mobj.momy, mobj.momz = mox, moy, moz;
		item.momx, item.momy, item.momz = itemMox, itemMoy, itemMoz;

		return; -- Goo d bye.

	-- Perform Primary Action
	elseif (IV2I[GC_JUMP].press)
		if (itemTable.type == "food")
			player.IV2C.Hunger = $ + itemTable.value;
			
			IV2CI.Grabbed = false;
			IV2CI.Holding = false;
			return; -- Goo d bye.
		end
	end
end

--[[
	function IV2CI.DisplayActions
		arguments:
			hud_t *v;
			player_t *player;
			table_t *itemTable;

		description:
			Displays Actions for a Specific Item
			
		possible returns:
			nil;
]]--
function IV2CI.DisplayActions(v, player, itemTable)
	if not (IV2CI.Grabbed) return; end

	v.drawString(100, 100, itemTable.actions.select, V_PERPLAYER, "small-right");
	v.drawString(50, 100, itemTable.actions.close, V_PERPLAYER, "small");
end