-- Inventory system by LJ Sonic

-- Todo (important)
-- Handle item data when putting/taking an item
-- Uncomment help line once the help manual is updated

-- Todo:
-- Preview when building
-- Animate animals in hand?
-- Handle multistate ground items?
-- Food conditions?
-- Add a way to change hunger/thirst default value
-- Better craft system?
-- Improve seeds
-- Improve campfires?
-- Remove Desolate Valley stuff
-- Drop carried item on death instead of destroying it

-- Todo (features):
-- Add commands for day/night light
-- Random animal spawn?
-- Random sceneries?
-- Disable night in some maps
-- BSZ berries?
-- Beds
-- Multi-line tips?
-- Books/Papers?

-- Todo (fixes):
-- Remove items and cancel actions when removing an item type
-- Remove N&D debug command
-- Use itemlib.items instead of just items
-- Remove Desolate Valley stuff
-- Fix options
-- Fix player deaths?


rawset(_G, "itemlib", {})
local itemlib = itemlib

itemlib.INVENTORY_SLOTS = 12
itemlib.MAX_ACTION_DIST = 128 * FRACUNIT
itemlib.MAX_ACTION_HEIGHT = 96 * FRACUNIT

itemlib.cfg = {
	slots = itemlib.INVENTORY_SLOTS,

	hunger = 10 * 60 * TICRATE,
	thirst = 10 * 60 * TICRATE,
	energy = 10 * 60 * TICRATE,

	timefactor = 90,
	daylight = 255,
	nightlight = 96
}

freeslot("SPR_ITEM", "sfx_iteat")

itemlib.cv_logrelevantitemactions = CV_RegisterVar({"logrelevantitemactions", "Off", 0, CV_OnOff})

itemlib.time = 8 * 3600 * TICRATE
itemlib.light = 255
itemlib.sectorlights = {}
itemlib.skylightenabled = true
local mapchanged = true

local items
local itemidtoindex

itemlib.mobjtypeactions = {}
itemlib.mobjtypeitemactions = {}

itemlib.menus = {}

function itemlib.itemnumber(p)
	return #p.items.itemid
end

function itemlib.itemtext(p, i)
	local it = p.items
	local item = itemlib.items[it.itemid[i]]
	local quantity = it.itemquantity[i]
	if not item.stack or quantity == 1
		return item.name:gsub("^%l", string.upper)
	else
		return quantity.." "..item.plural
	end
end

function itemlib.itemtip(p, choice)
	local itemid = p.items.itemid
	if #itemid ~= 0
		local item = itemlib.items[itemid[choice]]
		if item.stack and item.stack ~= 1
			return item.stack.." per slot"
		end
	end
end

function itemlib.itemtip2(p, choice)
	local itemid = p.items.itemid
	if #itemid ~= 0
		return itemlib.items[itemid[choice]].tip
	end
end

function itemlib.getCycledValueSin(low, high, speed)
	local base = sin(leveltime % speed * FRACUNIT / speed * FRACUNIT)
	return low + FixedMul(base + FRACUNIT, (high - low) / 2)
end

function itemlib.itemdrawextra(v, p)
	local itemid = p.items.itemid
	local menustates = p.menu
	local menustate = menustates[#menustates]
	local menu = menulib.menus[menustates.mod][menustate.id]
	for i = 1, #itemid
		local iteminfo = itemlib.items[itemid[i]]

		if not iteminfo.icon
			local basepatch = sprnames[iteminfo.mobjsprite] + R_Frame2Char(iteminfo.mobjframe)
			iteminfo.icon = basepatch.."0"
			if not v.patchExists(iteminfo.icon)
				iteminfo.icon = basepatch.."1"
			end
		end

		local patch = v.cachePatch(iteminfo.icon)

		if not iteminfo.iconscale
			local scale = (iteminfo.mobjscale or FRACUNIT) / 2
			local maxscale = 16 * FRACUNIT / max(patch.width, patch.height)
			iteminfo.iconscale = min(scale, maxscale)
		end

		local scale = iteminfo.iconscale
		if i == menustate.choice
			scale = itemlib.getCycledValueSin($, $ * 3 / 2, TICRATE)
		end

		local x, y = menulib.elementPosition(menu, i)
		x = ($ - 10) * FRACUNIT + (patch.leftoffset - patch.width / 2) * scale
		y = ($ + 2) * FRACUNIT + (patch.topoffset - patch.height / 2) * scale

		v.drawScaled(x, y, scale, patch)
	end
end

freeslot("MT_ITEMS_GROUNDITEM", "S_ITEMS_GROUNDITEM")

mobjinfo[MT_ITEMS_GROUNDITEM] = {
	-1,
	S_ITEMS_GROUNDITEM,
	0,
	S_NULL,
	sfx_None,
	0,
	sfx_None,
	S_NULL,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	8 * FRACUNIT,
	16 * FRACUNIT,
	0,
	0,
	0,
	sfx_None,
	MF_NOBLOCKMAP|MF_SCENERY,
	S_NULL
}

states[S_ITEMS_GROUNDITEM] = {SPR_NULL, 0, -1, nil, 0, 0, S_NULL}

function itemlib.spawnGroundItem(x, y, z, id)
	local iteminfo = itemlib.items[id]

	local mo = P_SpawnMobj(x, y, z, iteminfo.mobjtype)

	if iteminfo.mobjstate
		mo.state = iteminfo.mobjstate
	end

	if iteminfo.mobjscale
		mo.scale = iteminfo.mobjscale
	end

	return mo
end

itemlib.grounditemstatetoid = {}
itemlib.grounditemstate = 1

function itemlib.addItem(itemdef)
	itemdef.id = $ or itemdef.name

	local conflict = itemidtoindex[itemdef.id]
	if conflict
		itemlib.items[conflict] = itemdef
	else
		local i = #items + 1
		itemlib.items[i] = itemdef
		itemlib.items[itemdef.id] = itemdef
		itemidtoindex[itemdef.id] = i
	end

	-- Look for missing properties and replace them with their default values
	if itemdef.plural == false
		itemdef.plural = itemdef.name
	elseif not itemdef.plural
		if itemdef.name:sub(-1) == "y"
			itemdef.plural = itemdef.name:sub(1, -2).."ies"
		else
			itemdef.plural = itemdef.name.."s"
		end
	end
	if itemdef.stack == nil
		itemdef.stack = 1
	end
	if itemdef.mobjsprite
		itemdef.mobjframe = $ or 0
	else
		itemdef.mobjsprite = SPR_UNKN
		itemdef.mobjframe = 0
	end

	/*-- Create state if it doesn't exist already
	local exists = pcall(do return _G[itemdef.mobjstate] end)
	if exists
		itemdef.mobjstate = _G[$]
	else
		freeslot(itemdef.mobjstate)
		itemdef.mobjstate = _G[$]
		states[itemdef.mobjstate] = {
			sprite = itemdef.mobjsprite,
			frame = itemdef.mobjframe or 0,
			tics = -1,
			action = nil,
			var1 = 0,
			var2 = 0,
			nextstate = S_NULL
		}
	end*/

	/*if itemdef.mobjtype
		-- Create mobjtype if it doesn't exist already
		exists = pcall(do return _G[itemdef.mobjtype] end)
		if exists
			itemdef.mobjtype = _G[$]
		else
			freeslot(itemdef.mobjtype)
			itemdef.mobjtype = _G[$]
			mobjinfo[itemdef.mobjtype] = {
				-1,
				state,
				0,
				S_NULL,
				sfx_None,
				0,
				sfx_None,
				S_NULL,
				0,
				sfx_None,
				S_NULL,
				S_NULL,
				S_NULL,
				S_NULL,
				sfx_None,
				0,
				8 * FRACUNIT,
				16 * FRACUNIT,
				0,
				0,
				0,
				sfx_None,
				MF_NOBLOCKMAP|MF_SCENERY,
				S_NULL
			}
		end
	else
		itemdef.mobjtype = MT_ITEMS_GROUNDITEM
	end*/

	if not itemdef.actions
		-- Store all actions in a table
		local n = 1
		itemdef.actions = {}
		while itemdef["action"..n]
			table.insert(itemdef.actions, itemdef["action"..n])
			itemdef["action"..n] = nil
			n = $ + 1
		end
	end

	itemdef.mobjtypes = {}
	for _, action in ipairs(itemdef.actions)
		if action.mobjtype
			action.mobjtypes = {action.mobjtype}
		end

		if action.mobjtypes
			local newmobjtypes = {}
			for _, mobjtype in ipairs(action.mobjtypes)
				itemdef.mobjtypes[mobjtype] = true
				newmobjtypes[mobjtype] = true
			end
			action.mobjtypes = newmobjtypes
		end
	end

	if itemdef.mobjtype == MT_ITEMS_GROUNDITEM
		local statename = "S_ITEMS_GROUNDITEM"..itemlib.grounditemstate
		itemlib.grounditemstate = $ + 1
		freeslot(statename)
		itemdef.mobjstate = _G[statename]

		states[itemdef.mobjstate] = {
			sprite = itemdef.mobjsprite,
			frame = itemdef.mobjframe,
			tics = -1,
			action = nil,
			var1 = 0,
			var2 = 0,
			nextstate = S_NULL
		}
		itemlib.grounditemstatetoid[itemdef.mobjstate] = itemdef.id
	elseif itemdef.mobjtype
		itemlib.addMobjAction({
			mobjtype = itemdef.mobjtype,
			action = function(p, mo)
				local data
				if not itemdef.stack
					data = mo.itemdata
				end

				itemlib.carryItem(p, itemdef.id, data)
			end
		})
	end
	/*-- Create ground item action
	if not itemlib.mobjtypeactions[itemdef.mobjtype]
		itemlib.addMobjAction({
			mobjtype = itemdef.mobjtype,
			action = function(p, mo)
				local id = itemstatetoid[itemdef.mobjtype][mo.state]
				if not id return true end
				itemlib.carryItem(p, id)
			end
		})
	end
	if not itemstatetoid[itemdef.mobjtype]
		itemstatetoid[itemdef.mobjtype] = {}
	end
	itemstatetoid[itemdef.mobjtype][itemdef.mobjstate] = itemdef.id*/

	return itemlib.items[itemdef.id]
end

function itemlib.resetItems()
	items = {}
	itemlib.items = items
	itemidtoindex = {}
end

itemlib.resetItems()

local unknownitem = {
	name = "<unknown>",
	plural = "<unknown>",
	tip = "Unknown item id",
	stack = 1
}

function itemlib.removeItem(removeditem)
	items[itemidtoindex[removeditem]] = unknownitem
	itemidtoindex[name] = nil
end

function itemlib.removeItems(removeditems)
	for _, name in pairs(removeditems)
		items[itemidtoindex[name]] = unknownitem
		itemidtoindex[name] = nil
	end
end

function itemlib.removeOtherItems(keptitems)
	local newkeptitems = {}
	for _, name in pairs(keptitems)
		newkeptitems[name] = true
	end

	for _, name in pairs(itemlib.items)
		if not newkeptitems[name]
			itemlib.items[itemidtoindex[name]] = unknownitem
			itemidtoindex[name] = nil
		end
	end
end

function itemlib.itemName(id, n)
	return itemlib.items[id][n > 1 and "plural" or "name"]
end

local menulib = menulib

-- Returns the quantity of a given item in your inventory
function itemlib.countItems(p, id)
	local itemid = p.items.itemid
	local itemquantity = p.items.itemquantity

	-- Convert the name into a number
	if type(id) == "string"
		id = itemidtoindex[$]
	end

	local n = 0
	if itemlib.items[id].stack
		for slot = 1, #itemid
			if itemid[slot] == id
				n = $ + itemquantity[slot]
			end
		end
	else
		for slot = 1, #itemid
			if itemid[slot] == id
				n = $ + 1
			end
		end
	end

	return n
end

-- Returns true if the player can take a certain quantity of this item
function itemlib.canTakeItem(p, id, quantity, chest)
	-- Convert the name into a number
	if type(id) == "string"
		id = itemidtoindex[$]
	end

	local item = items[id]
	local itemid = chest and p.itemid or p.items.itemid

	-- If no quantity is specified, default it to 1
	if quantity == nil
		quantity = 1
	end

	-- Look if we have enough room in the inventory
	local numunusedslots = (chest and 16 or itemlib.INVENTORY_SLOTS) - #itemid
	if item.stack
		local itemquantity = chest and p.itemquantity or p.items.itemquantity
		local needed = quantity - numunusedslots * item.stack
		if needed <= 0
			return true
		else
			for slot = 1, #itemid
				if id == itemid[slot]
					needed = $ - item.stack + itemquantity[slot]
					if needed <= 0
						return true
					end
				end
			end
		end
	else
		return quantity <= numunusedslots
	end
end

-- Returns true if the player can take all these items
function itemlib.canTakeItems(p, itemlist, quantity, chest)
	if type(itemlist) ~= "table"
		return itemlib.canTakeItem(p, itemlist, quantity, chest)
	end

	local itemid = chest and p.itemid or p.items.itemid
	local itemquantity = chest and p.itemquantity or p.items.itemquantity
	local tmpitemid, tmpitemquantity = {}, {}
	for slot = 1, #itemid
		tmpitemid[slot], tmpitemquantity[slot] = itemid[slot], itemquantity[slot]
	end

	for i = 1, #itemlist
		local id, quantity
		if type(itemlist[i]) == "table"
			id = itemlist[i][1]
			quantity = itemlist[i][2] or 1
		else
			id = itemlist[i]
			quantity = 1
		end

		-- Convert the name into a number
		if type(id) == "string"
			id = itemidtoindex[$]
		end

		local item = items[id]

		if item.stack
			for slot = 1, #tmpitemid
				if id == tmpitemid[slot]
					local room = item.stack - tmpitemquantity[slot]

					tmpitemquantity[slot] = $ + min(room, quantity)

					quantity = $ - room
					if quantity <= 0
						break
					end
				end
			end

			if quantity > 0
				for slot = #tmpitemid + 1, chest and 16 or itemlib.INVENTORY_SLOTS
					tmpitemid[slot] = id
					tmpitemquantity[slot] = min(quantity, item.stack)

					quantity = $ - item.stack
					if quantity <= 0
						break
					end
				end
			end
		else
			for slot = #tmpitemid + 1, chest and 16 or itemlib.INVENTORY_SLOTS
				tmpitemid[slot] = id
				tmpitemquantity[slot] = 0

				quantity = $ - 1
				if quantity <= 0
					break
				end
			end
		end

		if quantity > 0
			return false
		end
	end

	return true
end

-- Adds a certain number of a specific item to your inventory.
-- <p> is the player who gets the items,
-- <id> is the name of the item, <quantity> is how many items you get,
-- <msg> and <fullmsg> are the messages displayed respectively when
-- the items are added to your inventory and when your inventory is full.
-- Only <p> and <id> are required, other parameters are optional.
-- Returns false if the inventory is full, returns true otherwise.
function itemlib.takeItem(p, id, quantity, msg, fullmsg, chest)
	-- Convert the name into a number
	if type(id) == "string"
		local name = id
		id = itemidtoindex[name]
		assert(id, 'unknown item "'..name..'"')
	end

	local item = items[id]
	local itemid = chest and p.itemid or p.items.itemid
	local itemquantity = chest and p.itemquantity or p.items.itemquantity

	local data
	if not item.stack
		data = quantity
		quantity = 1
	end

	-- If no quantity is specified, default it to 1
	if quantity == nil
		quantity = 1
	end

	-- If the inventory is full
	if not itemlib.canTakeItem(p, id, quantity, chest)
		if not chest
			if fullmsg
				CONS_Printf(p, fullmsg)
			elseif fullmsg == nil
				CONS_Printf(p, "Your inventory is full!")
			end
			S_StartSound(nil, sfx_lose, p)
		end
		return true
	end

	-- Notice the player that the items have been taken
	if msg
		CONS_Printf(p, msg)
	elseif msg == nil and not chest
		if quantity == 1
			CONS_Printf(p, "You take the "..item.name..".")
		else
			CONS_Printf(p, "You take "..quantity.." "..item.plural..".")
		end
	end

	-- Add the items to the inventory
	if item.stack
		for slot = 1, #itemid
			if id == itemid[slot]
				local room = item.stack - itemquantity[slot]

				itemquantity[slot] = $ + min(room, quantity)

				quantity = $ - room
				if quantity <= 0
					return false
				end
			end
		end

		for slot = #itemid + 1, chest and 16 or itemlib.INVENTORY_SLOTS
			itemid[slot] = id
			itemquantity[slot] = min(quantity, item.stack)

			quantity = $ - item.stack
			if quantity <= 0
				return false
			end
		end
	else
		local slot = #itemid + 1
		itemid[slot] = id
		itemquantity[slot] = data
		return false
	end
end

function itemlib.dropItem(p, id, quantity, chest)
	-- Convert the name into a number
	if type(id) == "string"
		id = itemidtoindex[$]
	end

	local it = p.items
	local menustate = not chest and p.menu and p.menu[#p.menu]
	local menu = menustate and menulib.menus["items"][menustate.id]
	local choice = menu and menu.layout == "grid" and menustate.id ~= "craft" and menustate.choice -- !!! Hack
	local item = items[id]
	local itemid = chest and p.itemid or it.itemid
	local itemquantity = chest and p.itemquantity or it.itemquantity

	local data
	if not item.stack
		data = quantity
		quantity = 1
	end

	-- If no quantity is specified, default it to 1
	if quantity == nil
		quantity = 1
	end

	if item.stack
		if choice
			if itemid[choice] == id
				local n = min(quantity, itemquantity[choice])
				quantity = $ - n
				itemquantity[choice] = $ - n
				if itemquantity[choice] == 0
					table.remove(itemid, choice)
					table.remove(itemquantity, choice)
				end
			end
		end

		for slot = 1, #itemid
			if itemid[slot] == id
				local n = min(quantity, itemquantity[slot])
				quantity = $ - n
				itemquantity[slot] = $ - n
				if itemquantity[slot] == 0
					table.remove(itemid, slot)
					table.remove(itemquantity, slot)
				end
			end
		end
	else
		for slot = 1, #itemid
			if itemid[slot] == id and itemquantity[slot] == data
				table.remove(itemid, slot)
				table.remove(itemquantity, slot)
			end
		end
	end

	if choice
		menustate.choice = max(1, min($, #itemid))
	end
end

function itemlib.areaContainsMobjs(x1, y1, z1, x2, y2, z2)
	for mo in mobjs.iterate()
		local r = mo.radius
		if mo.x + r > x1 and mo.x - r < x2
		and mo.y + r > y1 and mo.y - r < y2
		and mo.z + mo.height > z1 and mo.z < z2
			return true
		end
	end

	return false
end

function itemlib.positionContainsMobjs(x, y, z, radius, height)
	return itemlib.areaContainsMobjs(
		x - radius, y - radius, z,
		x + radius, y + radius, z + height
	)
end

/*function itemlib.(mo)
	local r = mo.radius
	return itemlib.areaContainsMobjs(
		mo.x - r, mo.y - r, mo.z,
		mo.x + r, mo.y + r, mo.z + mo.height
	)
end*/

local function lockPlayer(p)
	local it = p.items

	it.prevangleturn = p.cmd.angleturn
	it.prevaiming = p.cmd.aiming

	-- Save the thrust factor so we can restore it later
	it.thrustfactor = p.thrustfactor

	-- Prevent the player from moving
	p.thrustfactor = 0

	it.pflags = p.pflags & PF_FORCESTRAFE
	p.pflags = $ | PF_FORCESTRAFE

	it.pflags = $ | (p.pflags & PF_ANALOGMODE)
	p.pflags = $ & ~PF_ANALOGMODE
end

function itemlib.handleLockedPlayer(p)
	local it = p.items
	local cmd = p.cmd

	-- Prevent the player from moving or looking away
	if p.thrustfactor ~= 0
		it.thrustfactor = p.thrustfactor
		p.thrustfactor = 0
	end
	if cmd.angleturn ~= it.prevangleturn and p.mo and p.mo.valid
		p.mo.angle = it.prevangleturn * FRACUNIT
	end
	if cmd.aiming ~= it.prevaiming
		p.aiming = it.prevaiming * FRACUNIT
	end

	-- Force strafe mode while menu is open
	if not (p.pflags & PF_FORCESTRAFE)
		it.pflags = $ & ~PF_FORCESTRAFE
		p.pflags = $ | PF_FORCESTRAFE
	end

	-- Forbid analog mode while menu is open
	if p.pflags & PF_ANALOGMODE
		it.pflags = $ | PF_ANALOGMODE
		p.pflags = $ & ~PF_ANALOGMODE
	end

	if p.mo and p.mo.valid
		it.prevangleturn = p.mo.angle / FRACUNIT
	else
		it.prevangleturn = cmd.angleturn
	end
	it.prevaiming = p.aiming / FRACUNIT
end

local function unlockPlayer(p)
	local it = p.items

	-- Let the player move again
	p.thrustfactor = it.thrustfactor
	it.thrustfactor = nil

	if not (it.pflags & PF_FORCESTRAFE)
		p.pflags = $ & ~PF_FORCESTRAFE
	end

	if it.pflags & PF_ANALOGMODE
		p.pflags = $ | PF_ANALOGMODE
	end

	it.pflags = nil
	it.prevangleturn = nil
	it.prevaiming = nil
end

freeslot("MT_CARRIEDITEM", "S_CARRIEDITEM")

mobjinfo[MT_CARRIEDITEM] = {
	-1,
	S_CARRIEDITEM,
	0,
	S_NULL,
	sfx_None,
	0,
	sfx_None,
	S_NULL,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	16 * FRACUNIT,
	16 * FRACUNIT,
	0,
	0,
	0,
	sfx_None,
	MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_SCENERY|MF_NOCLIPHEIGHT,
	S_NULL
}

states[S_CARRIEDITEM] = {SPR_NULL, 0, -1, nil, 0, 0, S_NULL}

local function getCarriedItemPosition(pmo)
	local dist = pmo.radius * 2
	local angle = pmo.angle - 8192 * FRACUNIT -- ...I assume Sonic & co are right handed lol?
	return pmo.x + FixedMul(dist, cos(angle)), pmo.y + FixedMul(dist, sin(angle)), pmo.z + pmo.height / 2
end

addHook("MobjThinker", function(mo)
	local pmo = mo.target
	if not (pmo and pmo.valid)
		P_RemoveMobj(mo)
		return
	end

	-- Update the position of the carried item
	local x, y, z = getCarriedItemPosition(pmo)
	P_TeleportMove(mo, x, y, z)

	-- Run the item thinker if there is one
	local thinker = items[mo.itemid].mobjthinker
	if thinker
		thinker(mo)
	end
end, MT_CARRIEDITEM)

-- Puts an item in the hand of a player, replacing any existing one
function itemlib.carryItem(p, id, data)
	if not (p.mo and p.mo.valid) return end

	-- Convert the name into a number
	if type(id) == "string"
		id = itemidtoindex[$]
	end

	local iteminfo = itemlib.items[id]

	-- Remove the previously carried item if there is one
	if p.items.carrieditem
		itemlib.removeCarriedItem(p)
	end

	-- Spawn the carried item
	local x, y, z = getCarriedItemPosition(p.mo)
	local mo = P_SpawnMobj(x, y, z, MT_CARRIEDITEM)

	mo.itemid = id

	if data ~= nil
		mo.itemdata = data
	end

	mo.target = p.mo

	/*if iteminfo.mobjstate
		mo.state = iteminfo.mobjstate
	else*/
		mo.sprite = iteminfo.mobjsprite
		mo.frame = iteminfo.mobjframe
	--end

	if iteminfo.mobjscale
		mo.scale = iteminfo.mobjscale
	end

	p.items.carrieditem = mo

	return mo
end

function itemlib.removeCarriedItem(p)
	local it = p.items

	if not it.carrieditem return end

	if it.availableactions
		it.availableactions = nil
		it.lockeduntilnoinput = true
	end

	P_RemoveMobj(it.carrieditem)
	it.carrieditem = nil
	it.multiplecarrieditems = nil
end

local function betterPositionToPutItem(x, y, z, bestx, besty, bestz, px, py, pz)
	local olddelta = abs(bestz - pz)
	local newdelta = abs(z - pz)
	if newdelta < olddelta
		return true
	elseif newdelta == olddelta
		local olddist = R_PointToDist2(px, py, bestx, besty)
		local newdist = R_PointToDist2(px, py, x, y)
		return newdist > olddist
	else
		return false
	end
end

-- Spawns a mobj in front of a player
function itemlib.putItem(p, id, data)
	local iteminfo = itemlib.items[id]
	local mt = iteminfo.mobjtype

	local pmo = p.mo
	local pangle = pmo.angle
	local panglecos = cos(pangle)
	local panglesin = sin(pangle)

	local mindist = pmo.radius + mobjinfo[mt].radius
	local maxdist = pmo.radius * 3 + mobjinfo[mt].radius
	local maxheight = 64 * FRACUNIT

	local px = pmo.x
	local py = pmo.y
	local pz = pmo.z + pmo.height * 2 / 3
	local z1, z2 = pz - maxheight, pz + maxheight

	-- Find the nearest reachable solid FOF
	local bestx, besty, bestz
	for i = mindist, maxdist, 8 * FRACUNIT
		local x = px + FixedMul(i, panglecos)
		local y = py + FixedMul(i, panglesin)

		local s = R_PointInSubsector(x, y).sector
		if not bestz or betterPositionToPutItem(x, y, s.floorheight, bestx, besty, bestz, px, py, pz)
			bestx, besty, bestz = x, y, s.floorheight
		end
		for ff in s.ffloors()
			if z1 <= ff.topheight and z2 >= ff.bottomheight
			and ff.flags & FF_SOLID == FF_SOLID
			and betterPositionToPutItem(x, y, ff.topheight, bestx, besty, bestz, px, py, pz)
				bestx, besty, bestz = x, y, ff.topheight
			end
		end
	end

	-- Try spawning the mobj
	local mo
	if z1 <= bestz and z2 >= bestz
		mo = itemlib.spawnGroundItem(bestx, besty, bestz, id)
		if not P_CheckPosition(mo, bestx, besty, bestz)
			P_RemoveMobj(mo)
			mo = nil
		end
	end

	if mo
		mo.angle = pangle

		if data ~= nil
			if type(data) == "table"
				for k, v in pairs(data)
					mo[k] = v
				end
			else
				mo.itemdata = data
			end
		end
	else
		CONS_Printf(p, "You can't put this here!")
	end

	return mo
end

-- Called when a new map has just been loaded
local function initialiseMap()
	mapchanged = false

	itemlib.nobuildcampfire = mapheaderinfo[gamemap].nobuildcampfire == "true" and true or nil

	itemlib.desolatevalley = mapheaderinfo[gamemap].desolatevalley == "true" and {} or nil
	if itemlib.desolatevalley
		itemlib.desolatevalley.campfiresectors = {}
		for s in sectors.iterate
			local tag = s.tag
			if tag >= 1 and tag <= 3
				itemlib.desolatevalley.campfiresectors[tag] = #s
			end
		end

		itemlib.spawnCampfire(0, 0, 0, FRACUNIT, true)
	end

	itemlib.initialiseTime()
end

-- Called when a new player has just joined the server, or just to reset them
function itemlib.initialisePlayer(p)
	-- Remove carried item if the player has one
	if p.items and p.items.carrieditem and p.items.carrieditem.valid
		itemlib.removeCarriedItem(p)
	end

	p.items = {}
	local it = p.items

	it.itemid = {}
	it.itemquantity = {}

	it.hunger = itemlib.cfg.hunger
	it.thirst = itemlib.cfg.thirst
	it.energy = itemlib.cfg.energy

	it.prevbuttons = p.cmd.buttons
	it.prevforwardmove = p.cmd.forwardmove
	it.prevsidemove = p.cmd.sidemove

	--menulib.open(p, "help1", "items", 1) -- !!!!

	--itemlib.takeItem(p, "leaves", 32) -- !!!
end


local liquidflats = {}
do
	local function addWaterFlats(s, n)
		for i = 1, n
			local flat = s..i
			liquidflats[flat] = "water"
		end
	end

	-- Water
	for i = 1, 16
		liquidflats[("BWATER%02s"):format(i)] = "water"
	end
	addWaterFlats("FWATER", 16)
	addWaterFlats("LWATER", 16)
	addWaterFlats("WATER", 7)
	addWaterFlats("SURF0", 8)

	-- Goop
	for i = 1, 16
		liquidflats[("CHEMG%02s"):format(i)] = "goop"
	end
	liquidflats["VIOFLR"] = "goop"
end

function itemlib.checkLiquid(p)
	local pmo = p.mo
	local pangle = pmo.angle
	local panglecos = cos(pangle)
	local panglesin = sin(pangle)

	local maxdist = itemlib.MAX_ACTION_DIST
	local maxheight = itemlib.MAX_ACTION_HEIGHT

	local px = pmo.x
	local py = pmo.y
	local pz = pmo.z + pmo.height * 2 / 3
	local z1, z2 = pz - maxheight, pz + maxheight

	-- Check for water FOFs in front of the player
	for i = 0, maxdist, 8 * FRACUNIT
		local x = px + FixedMul(i, panglecos)
		local y = py + FixedMul(i, panglesin)
		local s = R_PointInSubsector(x, y).sector

		for ff in s.ffloors()
			if z1 <= ff.topheight and z2 >= ff.bottomheight
			and ff.topheight >= s.floorheight -- Liquid under the ground
			and ff.flags & FF_SWIMMABLE
				local pic = ff.sector.ceilingpic
				if liquidflats[pic] == "water"
					return "water"
				elseif liquidflats[pic] == "goop"
					return "goop"
				end
			end
		end
	end

	return nil
end

function itemlib.findAimedMobj(p, mobjtypes, mobjtypes2)
	local pmo = p.mo
	local pangle = pmo.angle

	local maxdist = itemlib.MAX_ACTION_DIST
	local maxheight = itemlib.MAX_ACTION_HEIGHT
	local maxangle = ANGLE_45

	-- Check for mobjs around the player
	local x, y, z = pmo.x, pmo.y, pmo.z
	local x1, y1, z1 = x - maxdist, y - maxdist, z - maxheight
	local x2, y2, z2 = x + maxdist, y + maxdist, z + maxheight
	local bestdelta, found = INT32_MAX, nil
	for mo in mobjs.iterate()
		if mo.x > x1 and mo.x < x2
		and mo.y > y1 and mo.y < y2
		and mo.z > z1 and mo.z < z2
			local dist = R_PointToDist2(x, y, mo.x, mo.y)
			if dist < maxdist
			and (mobjtypes[mo.type] or mobjtypes2[mo.type])
			and mo ~= pmo
				local angle = abs(pangle - R_PointToAngle2(x, y, mo.x, mo.y))
				if angle < maxangle
					-- Use some basic heuristic to determine if that mobj
					-- if more likely to be the one the player is thinking of
					local delta = FixedDiv(angle, maxangle) / 2
					            + FixedDiv(dist, maxdist)
					            + FixedDiv(abs(z - mo.z), maxheight)

					if delta < bestdelta
						bestdelta, found = delta, mo
					end
				end
			end
		end
	end

	return found
end


addHook("ThinkFrame", do
	local maxflamedist = 512 * FRACUNIT
	local campfires = itemlib.campfires

	if mapchanged
		initialiseMap()
	end

	itemlib.handleTime()

	for p in players.iterate
		local pmo = p.mo
		if pmo and not pmo.valid
			pmo = nil
		end

		-- If not done yet, initialise the player's table
		local it = p.items
		if not it
			itemlib.initialisePlayer(p)
			it = p.items
		end

		itemlib.handleHungerAndThirst(p)

		-- If the player was carrying an item that no longer exists, remove it
		local carrieditem = it.carrieditem
		if carrieditem and not carrieditem.valid
			it.carrieditem = nil
			it.multiplecarrieditems = nil
			if it.availableactions
				it.lockeduntilnoinput = true
				it.availableactions = nil
			end
		end

		if it.lockeduntilnoinput and not (p.cmd.forwardmove or p.cmd.sidemove)
			unlockPlayer(p)
			it.lockeduntilnoinput = nil
		end

		if not p.exiting
			if p.menu
				menulib.handle(p)
			end

			if it.availableactions
				itemlib.handleActionChoice(p)
			end

			if not (p.menu or it.availableactions or it.lockeduntilnoinput)
				if p.cmd.buttons & BT_CUSTOM1 and not (it.prevbuttons & BT_CUSTOM1) and pmo
					local item = it.carrieditem
					if item
						lockPlayer(p)
						it.availableactions = itemlib.getAvailableActions(p)
					else
						itemlib.triggerAction(p)
					end
				elseif p.cmd.buttons & BT_CUSTOM2 and not (it.prevbuttons & BT_CUSTOM2)
					local suffix = (p == server or IsPlayerAdmin(p)) and "host" or "player"
					menulib.open(p, "main"..suffix, "items", 1)
				end
			end
		else
			if p.menu
				menulib.close(p)
			end

			if it.carrieditem
				itemlib.removeCarriedItem(p)
			end
		end

		-- Lighten the player if there is a campfire nearby
		if not itemlib.desolatevalley and pmo
			local x, y = pmo.x, pmo.y
			for _, mo in ipairs(campfires)
				if mo.extravalue2 == 0 -- Not in a campfire spot
				and mo.cusval ~= 0 -- Still alive
				and P_AproxDistance(x - mo.x, y - mo.y) < maxflamedist -- Close enough
					pmo.frame = $ | FF_FULLBRIGHT
				end
			end
		end

		it.prevbuttons = p.cmd.buttons
		it.prevforwardmove = p.cmd.forwardmove
		it.prevsidemove = p.cmd.sidemove
	end
end)


for _, h in ipairs({
	"JumpSpecial",
	"AbilitySpecial",
	"SpinSpecial",
	"JumpSpinSpecial"
})
	addHook(h, function(p)
		if p.items and p.items.availableactions return true end
	end)
end

addHook("MobjDeath", function(mo)
	local p = mo.player
	if not (p and p.valid) return end
	local it = p.items
	if not it return end

	it.hunger = itemlib.cfg.hunger
	it.thirst = itemlib.cfg.thirst
	it.energy = itemlib.cfg.energy

	-- !!! rm
	if itemlib.desolatevalley
		it.itemid = {}
		it.itemquantity = {}
	end

	if it.carrieditem
		itemlib.removeCarriedItem(p)
	end
end, MT_PLAYER)

addHook("MapChange", do
	mapchanged = true
	itemlib.campfires = {}

	for p in players.iterate
		if p.menu
			menulib.close(p)
		end
	end
end)

addHook("NetVars", function(n)
	mapchanged = n($)

	itemlib.cfg = n($)

	itemlib.time = n($)
	itemlib.light = n($)
	itemlib.prevlight = n($)
	itemlib.sectorlights = n($)
	itemlib.skylightenabled = n($)

	itemlib.campfires = n($)

	itemlib.nobuildcampfire = n($)
	itemlib.desolatevalley = n($)
end)

COM_AddCommand("timefactor", function(p, n)
	if not n
		CONS_Printf(p, "Time factor is "..itemlib.cfg.timefactor..".")
		return
	end

	n = tonumber($)
	if n == nil
		CONS_Printf(p, "Invalid time factor")
		return
	elseif not (n >= 1 and n <= 600)
		CONS_Printf(p, "Time factor must range between 1 and 600.")
		return
	end

	itemlib.cfg.timefactor = n
end, 1)

COM_AddCommand("daylight", function(p, n)
	if not n
		CONS_Printf(p, "Day light is "..itemlib.cfg.daylight..".")
		return
	end

	n = tonumber($)
	if n == nil
		CONS_Printf(p, "Invalid day light")
		return
	elseif not (n >= 0 and n <= 255)
		CONS_Printf(p, "Day light must range between 0 and 255.")
		return
	end

	itemlib.cfg.daylight = n
end, 1)

COM_AddCommand("nightlight", function(p, n)
	if not n
		CONS_Printf(p, "Night light is "..itemlib.cfg.nightlight..".")
		return
	end

	n = tonumber($)
	if n == nil
		CONS_Printf(p, "Invalid night light")
		return
	elseif not (n >= 0 and n <= 255)
		CONS_Printf(p, "Night light must range between 0 and 255.")
		return
	end

	itemlib.cfg.nightlight = n
end, 1)

hud.add(function(v, p)
	itemlib.drawHungerAndThirstHud(v, p)

	if p.menu
		menulib.draw(v, p)
	else
		local it = p.items
		if not it return end

		if it.availableactions and it.carrieditem and it.carrieditem.valid
			itemlib.drawActionChoice(v, p)
		end
	end
end, "game")
