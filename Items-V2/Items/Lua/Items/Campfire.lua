-- Campfires

-- Todo:
-- Use itemlib.putItem or equivalent for building campfire
-- Improve handling of removed flames (do not remove the campfire)
-- Check for mobjs when building a campfire


local MAX_ACTION_DIST = 128 * FRACUNIT
local MAX_ACTION_HEIGHT = 96 * FRACUNIT

local CAMPFIRE_MIN_LIGHT, CAMPFIRE_MAX_LIGHT = 128, 224
local CAMPFIRE_UPDATE_FREQUENCY = TICRATE

local itemlib = itemlib

itemlib.campfirespots = {
	/*[1] = {
		{0, 2, 73},
		{95},
		{60, 150, 155},
		{out = {76, 152}, 76, 152, 119},
		{176},
		{27, 31, 57, 91},
		{177},
		{32, 141, 143, 153, 167, 168, 175, 181, 182},
		{94},
		{fof = {1192}, 142, 178},
	},
	[2] = {
		{47},
		{87, 110, 224},
		{240},
		{107},
		{46, 205, 264},
		{out = {79}, 79, 104, 109},
		{123, 124, 125, 126, 215, 216, 217},
		{137, 138, 139, 142, 144, 145, 147, 148},
		{161},
		{out = {153, 278}, fof = {1565}, 153, 278, 330},
		{135},
		{239},
		{260},
		{178, 179},
		{188},
		{191},
		{192},
		{186, 187},
		{out = {186, 187}, 182, 183, 184, 186, 187, 189, 190, 197, 279, 382, 384},
		{out = {184}, 182, 183, 184, 189, 190, 197, 384},
		{182, 183, 197},
		{279, 280, 281, 282, 283, 284, 381, 382, 383},
		{283, 284, 287, 377},
		{354, 374, 385},
		{out = {167, 218, 219}, 167, 169, 170, 218, 219},
		{168, 169, 170, 171, 201},
		{172},
		{95, 113, 173, 174, 175, 176, 177, 180, 244, 271, 295},
		{181, 200, 286, 368, 369},
		{358, 359, 366},
		{361, 362, 363, 366},
		{356, 375, 376},
	},
	[10] = {
		{28, 29},
		{272},
		{5},
		{27},
		{19, 268, 678, 680},
		{271, 676, 677, 679},
	},

	[655] = {
		{9, 180},
	},*/
}

for _, spots in pairs(itemlib.campfirespots)
	for _, spot in ipairs(spots)
		if not (spot.out or spot.fof)
			spot.out = {}
			local out = spot.out
			for i, s in ipairs(spot)
				out[i] = s
			end
		end
	end
end


freeslot("MT_ITEMS_CAMPFIRE", "S_ITEMS_CAMPFIRE", "sfx_itfire")

mobjinfo[MT_ITEMS_CAMPFIRE] = {
	spawnstate = S_ITEMS_CAMPFIRE,
	radius = 32 * FRACUNIT,
	height = 28 * FRACUNIT,
	flags = MF_SOLID
}

states[S_ITEMS_CAMPFIRE] = {SPR_ITEM, A, -1, nil, 0, 0, S_NULL}


freeslot("MT_ITEMS_EMBER", "S_ITEMS_EMBER")

mobjinfo[MT_ITEMS_EMBER] = {
	spawnstate = S_ITEMS_EMBER,
	radius = 4 * FRACUNIT,
	height = 4 * FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
}

states[S_ITEMS_EMBER] = {SPR_FBLL, A|FF_FULLBRIGHT, -1, nil, 0, 0, S_NULL}


itemlib.campfires = {}

itemlib.addMobjAction({
	mobjtype = MT_ITEMS_CAMPFIRE,
	action = function(p, mo)
		menulib.open(p, "campfire", "items")
		p.menu.tmp = mo
		return true
	end
})

itemlib.addMobjItemAction({
	name = "campfire",
	mobjtype = MT_ITEMS_CAMPFIRE,
	action = function(p, mo)
		local iteminfo = itemlib.items[p.items.carrieditem.itemid]

		if iteminfo.combustible
			if mo.extravalue1 == 0
				mo.frame = $ | FF_FULLBRIGHT
				mo.fuse = 4 * TICRATE
			end
			mo.extravalue1 = min($ + iteminfo.combustible / itemlib.cfg.timefactor, 8 * 3600 * TICRATE / itemlib.cfg.timefactor) -- !!!
			itemlib.removeCarriedItem(p)
			itemlib.spawnEmbers(mo, 128, 4)
			S_StartSound(mo, sfx_koopfr)
		elseif iteminfo.cookable
			itemlib.carryItem(p, iteminfo.cookable)
			itemlib.spawnEmbers(mo, 128, 4)
			S_StartSound(mo, sfx_koopfr)
		end
	end
})


freeslot("MT_ITEMS_LOG", "S_ITEMS_LOG")

mobjinfo[MT_ITEMS_LOG] = {
	spawnstate = S_ITEMS_LOG,
	radius = 32 * FRACUNIT,
	height = 28 * FRACUNIT,
	flags = MF_SOLID
}

states[S_ITEMS_LOG] = {SPR_ITEM, 0, -1, nil, 0, 0, S_NULL}

itemlib.addItem({
	id = "log",
	name = "log",
	tip = "Can be used to build a campfire",
	stack = 2,

	mobjsprite = SPR_ITEM,
	mobjframe = 0,
	mobjtype = MT_ITEMS_LOG,
	mobjscale = FRACUNIT / 2,

	combustible = 2 * 3600 * TICRATE
})


local function updateCampfireLight()
	if itemlib.desolatevalley
		local firelight = itemlib.campfires[1].cusval
		local campfiresectors = itemlib.desolatevalley.campfiresectors
		local sectors = sectors

		if firelight > 128
			local relativefirelight = firelight - 128
			for i, s in ipairs(campfiresectors)
				sectors[s].lightlevel = 128 + relativefirelight * i / 3
			end
		else
			for i, s in ipairs(campfiresectors)
				sectors[s].lightlevel = 128
			end
		end

		return
	end

	local spots = itemlib.campfirespots[gamemap]
	if not spots return end

	local light = itemlib.light
	local sectorlights = itemlib.sectorlights
	local sectors = sectors

	for _, mo in ipairs(itemlib.campfires)
		local spot = mo.extravalue2
		if spot ~= 0
			for _, s in ipairs(spots[spot])
				sectors[s].lightlevel = sectorlights[s] * light / 255
			end
		end
	end

	for _, mo in ipairs(itemlib.campfires)
		local spot = mo.extravalue2
		if spot ~= 0
			local firelight = mo.cusval
			if firelight ~= 0
				for _, s in ipairs(spots[spot])
					sectors[s].lightlevel = max($, firelight)
				end
			end
		end
	end
end

local function increaseCampfireLight(mo)
	if itemlib.desolatevalley
		local firelight = mo.cusval
		local campfiresectors = itemlib.desolatevalley.campfiresectors
		local sectors = sectors

		if firelight > 128
			local relativefirelight = firelight - 128

			for i, s in ipairs(campfiresectors)
				sectors[s].lightlevel = 128 + relativefirelight * i / 3
			end
		else
			for i, s in ipairs(campfiresectors)
				sectors[s].lightlevel = 128
			end
		end

		return
	end

	local firelight = mo.cusval
	local sectors = sectors
	for _, s in ipairs(itemlib.campfirespots[gamemap][mo.extravalue2])
		sectors[s].lightlevel = max($, firelight)
	end
end

local function checkCampfireSpots(mo)
	if itemlib.desolatevalley
		mo.extravalue2 = 1 -- !!!
		return
	end

	local spots = itemlib.campfirespots[gamemap]
	if not spots return end

	local z = mo.z
	local s = #mo.subsector.sector
	local tag = mo.subsector.sector.tag
	for i, spot in ipairs(spots)
		if spot.out
			for _, sector in ipairs(spot.out)
				if s == sector
					local outside = true
					for ff in sectors[sector].ffloors()
						if z < ff.topheight
							outside = false
							break
						end
					end
					if outside
						mo.extravalue2 = i
						return
					end
				end
			end
		end

		if spot.fof
			for _, linenum in ipairs(spot.fof)
				local line = lines[linenum]
				if tag == line.tag and z < line.frontsector.floorheight
					mo.extravalue2 = i
					return
				end
			end
		end
	end
end

function itemlib.spawnCampfire(x, y, z, scale, flames)
	local campfire = P_SpawnMobj(x, y, z, MT_ITEMS_CAMPFIRE)
	campfire.scale = scale
	if not P_CheckPosition(campfire, x, y, z) or P_FloorzAtPos(x, y, z, campfire.height) ~= z
		P_RemoveMobj(campfire)
		return nil
	end

	-- Add the campfire to the list of campfires
	table.insert(itemlib.campfires, campfire)

	campfire.frame = $ | FF_FULLBRIGHT

	-- Spawn flames
	/*campfire.flames = {}
	z = $ + campfire.height
	local radius = 32 * scale
	local radius2 = radius * 3 / 4
	for i, coords in pairs({
		{x, y},
		{x + radius, y},
		{x, y + radius},
		{x - radius, y},
		{x, y - radius},
		{x + radius2, y + radius2},
		{x - radius2, y + radius2},
		{x - radius2, y - radius2},
		{x + radius2, y - radius2}
	})
		local flame = P_SpawnMobj(coords[1], coords[2], z, MT_FLAME)
		flame.state = P_RandomRange(S_FLAME1, S_FLAME4)
		flame.tics = P_RandomRange(1, states[flame.state].tics)
		flame.scale = scale
		flame.target = campfire
		campfire.flames[i] = flame
	end*/

	campfire.flames = {}
	if flames
		for i = 1, 12
			local angle = P_RandomRange(-FRACUNIT / 2, FRACUNIT / 2 - 1) * FRACUNIT
			local radius = P_RandomRange(16, 32) * scale / FRACUNIT
			local flame = P_SpawnMobj(campfire.x + radius * cos(angle), campfire.y + radius * sin(angle), campfire.z + campfire.height, MT_FLAME)
			flame.scale = scale
			flame.target = campfire
			campfire.flames[i] = flame
		end
		campfire.cusval = CAMPFIRE_MAX_LIGHT
	else
		-- Spawn a flame in the center
		local flame = P_SpawnMobj(x, y, z + campfire.height, MT_FLAME)
		flame.scale = scale
		flame.target = campfire
		campfire.flames[1] = flame
		campfire.cusval = CAMPFIRE_MIN_LIGHT
	end

	-- Make the fire last for about 8 hours
	campfire.extravalue1 = 8 * 3600 * TICRATE / itemlib.cfg.timefactor
	campfire.fuse = CAMPFIRE_UPDATE_FREQUENCY

	-- Check if the campfire is in a special campfire spot and light around it if so
	checkCampfireSpots(campfire)
	if campfire.extravalue2 ~= 0
		increaseCampfireLight(campfire)
	end

	-- Make a fire sound
	S_StartSound(mo, sfx_itfire)
	campfire.cvmem = 3

	return campfire
end

function itemlib.removeCampfire(mo)
	-- Stop lightning
	mo.cusval = 0
	updateCampfireLight()

	-- Remove flames
	for _, flame in ipairs(mo.flames)
		-- Set the flame target to nil to prevent its MobjRemoved
		-- hook from being called, as it has side-effects
		flame.target = nil

		-- Remove the flame
		P_RemoveMobj(flame)
	end

	-- Remove from the campfire list
	for i, campfire in ipairs(itemlib.campfires)
		if campfire == mo
			table.remove(itemlib.campfires, i)
			break
		end
	end

	-- Remove campfire itself
	P_RemoveMobj(mo)
end

function itemlib.buildCampfire(p, scale)
	if not p.mo return end

	local x = p.mo.x + 128 * cos(p.mo.angle)
	local y = p.mo.y + 128 * sin(p.mo.angle)
	local z = p.mo.z
	local campfire = itemlib.spawnCampfire(x, y, z, scale)
	if not campfire
		CONS_Printf(p, "You can't build a campfire here!")
		return
	end

	S_StartSound(campfire, sfx_koopfr)
end

itemlib.addCraft({
	name = "Little campfire",
	resources = {"log"},
	action = function(p)
		itemlib.buildCampfire(p, FRACUNIT / 2)
	end
})

itemlib.addCraft({
	name = "Medium campfire",
	resources = {{"log", 2}},
	action = function(p)
		itemlib.buildCampfire(p, FRACUNIT * 3 / 4)
	end
})

itemlib.addCraft({
	name = "Tall campfire",
	resources = {{"log", 4}},
	action = function(p)
		itemlib.buildCampfire(p, FRACUNIT)
	end
})

function itemlib.spawnEmbers(campfire, n, speed)
	/*for _ = 1, n
		local angle = P_RandomRange(-FRACUNIT / 2, FRACUNIT / 2 - 1) * FRACUNIT
		local radius = P_RandomKey(33) * campfire.scale / FRACUNIT
		local ember = P_SpawnMobj(campfire.x + radius * cos(angle), campfire.y + radius * sin(angle), campfire.z + campfire.height, MT_ITEMS_EMBER)

		angle = P_RandomRange(-FRACUNIT / 2, FRACUNIT / 2 - 1) * FRACUNIT
		local vangle = P_RandomRange(1, FRACUNIT / 4) * FRACUNIT
		local speed = P_RandomChance(FRACUNIT / 16) and P_RandomRange(257, 512) or P_RandomRange(1, 256) * speed
		ember.momx = FixedMul(cos(angle), cos(vangle)) * speed / 256
		ember.momy = FixedMul(sin(angle), cos(vangle)) * speed / 256
		ember.momz = sin(vangle) * speed / 256

		ember.scale = P_RandomRange(FRACUNIT / 16, FRACUNIT / 4)
		ember.fuse = P_RandomRange(TICRATE, 8 * TICRATE)
	end*/
end

addHook("MobjFuse", function(mo)
	local flames = mo.flames
	local FRACUNIT = FRACUNIT

	-- Update the combustible quantity
	mo.extravalue1 = $ - CAMPFIRE_UPDATE_FREQUENCY

	-- No more combustible
	if mo.extravalue1 <= 0
		-- Remove all flames
		for _, flame in ipairs(flames)
			flame.target = nil
			P_RemoveMobj(flame)
		end
		mo.flames = {}

		-- Stop lightning
		if mo.cusval ~= 0
			mo.cusval = 0
			updateCampfireLight()
		end
		mo.frame = $ & ~FF_FULLBRIGHT

		return true
	end

	-- Calculate the number of flames basing on the combustible quantity
	--local n = min(mo.extravalue1 * 12 / (6 * 3600 * TICRATE / itemlib.cfg.timefactor, 12)
	local n = min(mo.extravalue1 * 12 / (756000 / itemlib.cfg.timefactor), 12)

	-- Spawn embers
	itemlib.spawnEmbers(mo, P_RandomRange(0, max(n, 4)), 1)

	-- Make a fire ambience sound
	mo.cvmem = $ + 1
	if mo.cvmem == 4
		mo.cvmem = 0
		S_StartSound(mo, sfx_itfire)
	end

	-- Update the flames
	if #flames == n -- Move a flame
		if n ~= 0
			local angle = P_RandomRange(-FRACUNIT / 2, FRACUNIT / 2 - 1) * FRACUNIT
			local radius = P_RandomRange(16, 32) * mo.scale / FRACUNIT
			local flame = flames[1]
			table.remove(flames, 1)
			P_TeleportMove(flame, mo.x + radius * cos(angle), mo.y + radius * sin(angle), mo.z + mo.height)
			flames[n] = flame
		end
	elseif #flames > n -- Remove a flame
		flames[1].target = nil
		P_RemoveMobj(flames[1])
		table.remove(flames, 1)
		local firelight = #flames ~= 0 and CAMPFIRE_MIN_LIGHT + #flames * (CAMPFIRE_MAX_LIGHT - CAMPFIRE_MIN_LIGHT) / 12 / 32 * 32 or 0
		if firelight ~= mo.cusval
			mo.cusval = firelight
			updateCampfireLight()
		end
	else -- Spawn a flame
		local angle = P_RandomRange(-FRACUNIT / 2, FRACUNIT / 2 - 1) * FRACUNIT
		local radius = P_RandomRange(16, 32) * mo.scale / FRACUNIT
		local flame = P_SpawnMobj(mo.x + radius * cos(angle), mo.y + radius * sin(angle), mo.z + mo.height, MT_FLAME)
		flame.scale = mo.scale
		flame.target = mo
		flames[#flames + 1] = flame
		local firelight = CAMPFIRE_MIN_LIGHT + #flames * (CAMPFIRE_MAX_LIGHT - CAMPFIRE_MIN_LIGHT) / 12 / 32 * 32
		if firelight ~= mo.cusval
			mo.cusval = firelight
			if mo.extravalue2 ~= 0
				increaseCampfireLight(mo)
			end
		end
	end

	mo.fuse = CAMPFIRE_UPDATE_FREQUENCY
	return true
end, MT_ITEMS_CAMPFIRE)

addHook("MobjRemoved", function(mo)
	if mo.target and mo.target.valid and mo.target.type == MT_ITEMS_CAMPFIRE
		local campfire = mo.target
		for i, flame in ipairs(campfire.flames)
			if mo == flame
				table.remove(campfire.flames, i)
				local firelight
				if #campfire.flames ~= 0
					firelight = CAMPFIRE_MIN_LIGHT + #campfire.flames * (CAMPFIRE_MAX_LIGHT - CAMPFIRE_MIN_LIGHT) / 12 / 32 * 32
				else
					firelight = 0
				end
				if firelight ~= campfire.cusval
					campfire.cusval = firelight
					updateCampfireLight()
				end
				return
			end
		end
	end
end, MT_FLAME)

itemlib.menus.campfire = {
	w = 96, h = 32,
	condition = function(p)
		local campfire, pmo = p.menu.tmp, p.mo
		return campfire and campfire.valid
		and pmo and pmo.valid and pmo.health > 0
		and R_PointToDist2(pmo.x, pmo.y, campfire.x, campfire.y) <= MAX_ACTION_DIST
		and campfire.z >= pmo.z - MAX_ACTION_HEIGHT and campfire.z <= pmo.z + MAX_ACTION_HEIGHT
	end,
	/*{
		text = "Feed/Cook",
		tip = "Feed the fire or cook food",
		ok = "campfire_feed_or_cook"
	},*/
	{
		text = "Cancel",
		tip = "Don't do anything",
		ok = function(p)
			menulib.close(p)
		end
	},
	{
		text = "Destroy",
		tip = "Destroy the campfire",
		ok = function(p)
			if itemlib.cv_logrelevantitemactions.value
				CONS_Printf(server, p.name.." destroys a campfire.")
			end

			itemlib.removeCampfire(p.menu.tmp)
			menulib.close(p)
		end
	}
}

itemlib.menus.campfire_feed_or_cook = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 96,
	columns = 2,
	step = 16,
	leftmargin = 20,
	condition = function(p)
		local campfire, pmo = p.menu.tmp, p.mo
		return campfire and campfire.valid
		and pmo and pmo.valid and pmo.health > 0
		and R_PointToDist2(pmo.x, pmo.y, campfire.x, campfire.y) <= MAX_ACTION_DIST
		and campfire.z >= pmo.z - MAX_ACTION_HEIGHT and campfire.z <= pmo.z + MAX_ACTION_HEIGHT
	end,
	choices = itemlib.itemnumber,
	text = itemlib.itemtext,
	tip = itemlib.itemtip,
	tip2 = itemlib.itemtip2,
	drawextra = itemlib.itemdrawextra,
	ok = function(p, choice)
		local campfire = p.menu.tmp
		local id = p.items.itemid[choice]
		local name = itemlib.items[id].name
		if name == "log"
			if campfire.extravalue1 == 0
				campfire.frame = $ | FF_FULLBRIGHT
				campfire.fuse = 4 * TICRATE
			end
			campfire.extravalue1 = min($ + 4 * 3600 * TICRATE / itemlib.cfg.timefactor, 8 * 3600 * TICRATE / itemlib.cfg.timefactor) -- !!!
			itemlib.spawnEmbers(campfire, 128, 4)
			itemlib.dropItem(p, id)
			CONS_Printf(p, "You throw a log in the flames.")
			S_StartSound(campfire, sfx_koopfr)
		elseif name == "leaves"
			if campfire.extravalue1 == 0
				campfire.frame = $ | FF_FULLBRIGHT
				campfire.fuse = 4 * TICRATE
			end
			campfire.extravalue1 = min($ + 2 * 3600 * TICRATE / itemlib.cfg.timefactor, 8 * 3600 * TICRATE / itemlib.cfg.timefactor) -- !!!
			itemlib.spawnEmbers(campfire, 128, 4)
			itemlib.dropItem(p, id)
			CONS_Printf(p, "You throw some leaves in the flames.")
			S_StartSound(campfire, sfx_koopfr)
		elseif name == "bird" or name == "red bird"
			itemlib.dropItem(p, id)
			itemlib.takeItem(p, "cooked bird", 1, "You cook the bird. It looks a bit less lively than before.")
		elseif name == "bunny"
			itemlib.dropItem(p, id)
			itemlib.takeItem(p, "cooked bunny", 1, "You cook the bunny. It will never jump again.")
		elseif name == "mouse"
			itemlib.dropItem(p, id)
			itemlib.takeItem(p, "cooked mouse", 1, "You cook the mouse. It never got the cheese.")
		elseif name == "chicken"
			itemlib.dropItem(p, id)
			itemlib.takeItem(p, "cooked chicken", 1, "You cook the chicken. It will never fly again. Who cares, chickens can't fly anyway.")
		elseif name == "cow"
			itemlib.dropItem(p, id)
			itemlib.takeItem(p, "cooked cow", 1, "You cook the cow. Smells like milk.")
		else
			CONS_Printf(p, "You may only cook food or use logs or leaves to feed the fire.")
		end
	end
}
