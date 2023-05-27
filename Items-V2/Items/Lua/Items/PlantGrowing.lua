-- Plant growing

-- Todo:
-- Way to add new grass flats
-- Improve
-- Check for stuck flowers
-- Handle Botanic Serenity Zone plants
-- CEZ grass


local grassflats = {}

function itemlib.addGrass(flat)
	grassflats[flat] = true
end

for _, flat in ipairs({
	"DCZGRASS",
	"GFZFLR02",
	"GFZFLR10",
	"GRASS1",
	"GRASS2",
	"GRASS3",
	"GRASSY",
	"JNGGRS01",
	"JNGGRS02",
	"JNGGRS03",
	"JNGGRS04",
	"JNGGRS05",
	"JNGGRS06",
	"JNGGRS07",
	"JNGGRS08",
	"JNGGRS09",
	"JNGGRS10",
	"JNGGRS11",
	"JNGGRS12",
	"LFZFLR2",
	"LFZFLR3",

	"CEZFLR02",
	"CEZFLR03",
	"CEZFLR05",
	"CEZFLR12",
	"CEZFLR13",
})
	itemlib.addGrass(flat)
end


freeslot("MT_GROWINGPLANT", "S_GROWINGPLANT")

mobjinfo[MT_GROWINGPLANT] = {
	-1,
	S_GROWINGPLANT,
	1000,
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
	32 * FRACUNIT,
	0,
	100,
	0,
	sfx_None,
	MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	S_NULL
}

states[S_GROWINGPLANT] = {SPR_FWR3, 0, -1, nil, 0, 0, S_NULL}


-- Handle plant growing
addHook("MobjFuse", function(mo)
	local plant = P_SpawnMobj(mo.x, mo.y, mo.z, mo.extravalue1)
	/*if not P_CheckPosition(plant, plant.x, plant.y, plant.z)
		print("Cannot grow here!")
		P_RemoveMobj(plant)
	end*/
end, MT_GROWINGPLANT)

-- Handle bush spawning
addHook("MobjSpawn", function(mo)
	mo.fuse = P_RandomRange(180, 360) * TICRATE
end, MT_BUSH)

-- Handle bush growing
addHook("MobjFuse", function(mo)
	P_SpawnMobj(mo.x, mo.y, mo.z, MT_BERRYBUSH)
end, MT_BUSH)


local function isObjectOnGrass(mo)
	local s = R_PointInSubsector(mo.x, mo.y).sector

	local grassflats = grassflats
	if s.floorheight == mo.z
		local pic = s.floorpic
		if grassflats[pic]
			return true
		end
	end

	for ff in s.ffloors()
		if ff.flags & FF_SOLID and ff.flags & FF_RENDERPLANES
			local pic = ff.toppic
			if grassflats[pic]
				return true
			end
		end
	end

	return false
end

-- !!!
function itemlib.plant(p, planttype, sprite, frame)
	local mo = p.mo
	if not (mo and mo.valid) return true end

	if not isObjectOnGrass(mo)
		CONS_Printf(p, "You can only plant on grass.")
		return true
	end

	local bud = P_SpawnMobj(mo.x, mo.y, mo.z, MT_GROWINGPLANT)
	bud.extravalue1 = planttype
	if sprite ~= nil
		bud.sprite = sprite
		bud.frame = frame ~= nil and frame or 0
	end
	bud.fuse = P_RandomRange(180, 360) * TICRATE

	CONS_Printf(p, "You plant the seed.")
end