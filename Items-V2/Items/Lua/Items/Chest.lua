-- Chests

-- Todo:
-- Check for mobjs when putting a chest


freeslot("MT_ITEMS_CHEST", "S_ITEMS_CHEST")

mobjinfo[MT_ITEMS_CHEST] = {
	-1,
	S_ITEMS_CHEST,
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
	24 * FRACUNIT,
	40 * FRACUNIT,
	0,
	0,
	0,
	sfx_None,
	MF_SOLID,
	S_NULL
}

states[S_ITEMS_CHEST] = {SPR_ITEM, B, -1, nil, 0, 0, S_NULL}

itemlib.addItem({
	name = "chest",
	tip = "A chest xd",
	storable = false,

	mobjsprite = SPR_ITEM,
	mobjframe = B,
	mobjtype = MT_ITEMS_CHEST
})

itemlib.addMobjAction({
	mobjtype = MT_ITEMS_CHEST,
	action = function(p, mo)
		menulib.open(p, "chest", "items")
		p.menu.tmp = mo
		return true
	end
})

itemlib.addMobjItemAction({
	name = "store in chest",
	mobjtype = MT_ITEMS_CHEST,
	action = function(p, mo)
		local id = p.items.carrieditem.itemid

		local data
		if itemlib.items[id].stack -- Stackable
			data = 1 -- Quantity
		else
			data = p.items.carrieditem.itemdata -- Custom data
		end

		if itemlib.takeItem(mo, id, data, false, false, true)
			CONS_Printf(p, "The chest is full!")
			return
		end

		itemlib.removeCarriedItem(p)
	end
})

function itemlib.spawnChest(x, y, z)
	local chest = P_SpawnMobj(x, y, z, MT_ITEMS_CHEST)

	if not P_CheckPosition(chest, x, y, z) or P_FloorzAtPos(x, y, z, chest.height) ~= z
		P_RemoveMobj(chest)
		return nil
	end

	return chest
end

function itemlib.buildChest(p)
	if not p.mo return end

	if not itemlib.spawnChest(p.mo.x + 128 * cos(p.mo.angle), p.mo.y + 128 * sin(p.mo.angle), p.mo.z)
		CONS_Printf(p, "You can't put a chest here!")
		return
	end
end

itemlib.addCraft({
	name = "Chest",
	resources = {{"log", 2}},
	action = function(p)
		itemlib.buildChest(p)
	end
})

addHook("MobjSpawn", function(mo)
	mo.itemid = {}
	mo.itemquantity = {}
end, MT_ITEMS_CHEST)

local function chestCondition(p, menustate)
	local chest, pmo = p.menu.tmp, p.mo
	return chest and chest.valid
	and pmo and pmo.valid and pmo.health > 0
	and R_PointToDist2(pmo.x, pmo.y, chest.x, chest.y) <= itemlib.MAX_ACTION_DIST
	and chest.z >= pmo.z - itemlib.MAX_ACTION_HEIGHT
	and chest.z <= pmo.z + itemlib.MAX_ACTION_HEIGHT
end

itemlib.menus.chest = {
	w = 96, h = 32,
	condition = chestCondition,
	{
		text = "Take",
		tip = "Open the chest to take an item",
		ok = "take_item_from_chest"
	},
	{
		text = "Store",
		tip = "Open the chest to store an item",
		ok = "put_item_in_chest"
	},
	{
		text = "Hold",
		tip = "Hold the chest",
		ok = function(p)
			local chest = p.menu.tmp

			itemlib.carryItem(
				p,
				"chest",
				{itemid = chest.itemid, itemquantity = chest.itemquantity}
			)

			P_RemoveMobj(chest)
		end
	},
	{
		text = "Destroy",
		tip = "Destroy the chest",
		ok = function(p)
			if itemlib.cv_logrelevantitemactions.value
				CONS_Printf(server, p.name.." destroys a chest.")
			end

			P_RemoveMobj(p.menu.tmp)
		end
	}
}

itemlib.menus.take_item_from_chest = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 128,
	columns = 2,
	step = 16,
	leftmargin = 20,
	condition = chestCondition,
	choices = function(p)
		local chest = p.menu.tmp
		return chest and chest.valid and #chest.itemid or 0
	end,
	text = function(p, i, menustate)
		local chest = p.menu.tmp
		local item = itemlib.items[chest.itemid[i]]
		local quantity = p.menu.tmp.itemquantity[i]
		if not item.stack or quantity == 1
			return item.name:gsub("^%l", string.upper)
		else
			return quantity.." "..item.plural
		end
	end,
	tip = function(p, choice)
		local chest = p.menu.tmp
		if #chest.itemid ~= 0
			local item = itemlib.items[chest.itemid[choice]]
			if item.stack ~= 1
				return item.stack.." per slot"
			end
		end
	end,
	tip2 = function(p, choice)
		local chest = p.menu.tmp
		if #chest.itemid ~= 0
			return itemlib.items[chest.itemid[choice]].tip
		end
	end,
	drawextra = function(v, p)
		local chest = p.menu.tmp
		local itemid = chest.itemid
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
				local maxscale = 16 * FRACUNIT / max(patch.width, patch.height)
				iteminfo.iconscale = min(FRACUNIT / 2, maxscale)
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
	end,
	ok = function(p, choice)
		local chest = p.menu.tmp
		local id = chest.itemid[choice]

		local data
		if itemlib.items[id].stack -- Stackable
			data = 1 -- Quantity
		else
			data = chest.itemquantity[choice] -- Custom data
		end

		if itemlib.takeItem(p, id, data, false) return end

		itemlib.dropItem(chest, id, data, true)
		p.menu[#p.menu].choice = max(1, min($, #chest.itemid))
	end
}

itemlib.menus.put_item_in_chest = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 96,
	columns = 2,
	step = 16,
	leftmargin = 20,
	condition = chestCondition,
	choices = itemlib.itemnumber,
	text = itemlib.itemtext,
	tip = itemlib.itemtip,
	tip2 = itemlib.itemtip2,
	drawextra = itemlib.itemdrawextra,
	ok = function(p, choice)
		local chest = p.menu.tmp
		local id = p.items.itemid[choice]

		local data
		if itemlib.items[id].stack -- Stackable
			data = 1 -- Quantity
		else
			data = p.items.itemquantity[choice] -- Custom data
		end

		if itemlib.takeItem(chest, id, data, false, false, true)
			CONS_Printf(p, "The chest is full!")
			return
		end

		itemlib.dropItem(p, id, data)
	end
}