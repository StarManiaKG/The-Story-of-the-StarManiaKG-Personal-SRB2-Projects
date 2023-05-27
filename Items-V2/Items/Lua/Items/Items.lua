-- Various items

-- Todo:
-- Fix broken monitors being pickable


itemlib.addItem({
	name = "berry",
	tip = "Just a totally normal berry",
	stack = 6,

	mobjsprite = SPR_ITEM,
	mobjframe = C,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "eat",
		action = function(p)
			if itemlib.eat(p, itemlib.cfg.hunger / 10) return true end
			if p.items.hunger == itemlib.cfg.hunger
				CONS_Printf(p, "You eat a berry.\nYou are satiated.")
			else
				CONS_Printf(p, "You eat a berry.\nThat is delicious.")
			end
		end
	}
})

itemlib.addItem({
	id = "gfz_bush_seed",
	name = "GFZ bush seed",
	tip = "A... bush seed. Yeah",
	stack = 12,

	mobjsprite = SPR_ITEM,
	mobjframe = D,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "plant",
		action = function(p)
			return itemlib.plant(p, MT_BUSH, SPR_ITEM, D)
		end
	}
})

itemlib.addItem({
	name = "leaves",
	plural = false,
	tip = "Not a verb but a noun (btw it can be used to light a campfire)",
	stack = 8,

	mobjsprite = SPR_ITEM,
	mobjframe = G,
	mobjtype = MT_ITEMS_GROUNDITEM,

	combustible = 2 * 3600 * TICRATE,

	action1 = {
		name = "admire",
		action = function(p)
			CONS_Printf(p, "WOA!! u gota... leaves!!!")
			return true
		end
	}
})


// Greenflower Zone items
/*{
	name = "water bottle",
	tip = "A bottle filled with water",

	mobjsprite = SPR_UNKN,
	mobjframe = 0,

	effect = function(p, it)
		if itemlib.drink(p, itemlib.cfg.thirst / 2) return true end
		if p.items.thirst == itemlib.cfg.thirst
			CONS_Printf(p, "You drink the water.\nYou're filled with\nWATER.")
		else
			CONS_Printf(p, "You drink the water.\nThat is wet.")
		end
	end
},*/
/*{
	name = "Flowey",
	plural = false,
	tip = "A REALLY lively flower",

	mobjsprite = SPR_UNKN,
	mobjframe = 0,

	effect = function(p)
		CONS_Printf(p, "The flower looks a bit more lively than usual.")
	end
},*/

/*{
	name = "goop bottle",
	tip = "A bottle filled with goop",
	effect = function(p, it)
		CONS_Printf(p, "Did you seriously think about drinking THAT?")
		return true
	end
},*/

// Deep Sea Zone items
/*itemlib.addItem({
	name = "coral",
	tip = "Usually found in caves",
	stack = 3,

	mobjsprite = SPR_UNKN,
	mobjframe = 0,

	action1 = {
		name = "admire",
		action = function(p)
			CONS_Printf(p, "You look at the coral.\nIt's... rocky.")
			return true
		end
	}
})

itemlib.addItem({
	name = "blue crystal",
	tip = "A blue crystal",
	stack = 3,

	mobjsprite = SPR_UNKN,
	mobjframe = 0,

	action1 = {
		name = "admire",
		action = function(p)
			CONS_Printf(p, "You look at the blue crystal.\nIt's... blue.")
			return true
		end
	}
})

// Arid Canyon Zone items
itemlib.addItem({
	name = "cactus",
	plural = "cacti",
	tip = "Some kind of spiky food",
	stack = 5,

	mobjsprite = SPR_UNKN,
	mobjframe = 0,

	action1 = {
		name = "admire",
		action = function(p)
			CONS_Printf(p, "You look at the cactus.\nIt's green and spiky.")
			return true
		end
	}
})

// Miscellaneous
itemlib.addItem({
	name = "candy cane",
	tip = 'Did you know? "Cane" means "female duck" in French. This can be eaten too.',
	stack = 10,

	mobjsprite = SPR_UNKN,
	mobjframe = 0,

	action1 = {
		name = "admire",
		action = function(p)
			CONS_Printf(p, "You look at the candy cane.\nIt looks delicious.")
			return true
		end
	}
})*/

for _, item in ipairs({
	{"ring monitor",              MT_RING_BOX,       SPR_TVRI},
	{"super sneakers monitor",    MT_SNEAKERS_BOX,   SPR_TVSS},
	{"invincibility monitor",     MT_INVULN_BOX,     SPR_TVIV},
	{"extra life monitor",        MT_1UP_BOX,        SPR_TV1U},
	{"attraction shield monitor", MT_ATTRACT_BOX,    SPR_TVAT},
	{"force shield monitor",      MT_FORCE_BOX,      SPR_TVFO},
	{"armageddon shield monitor", MT_ARMAGEDDON_BOX, SPR_TVAR},
	{"whirldwind shield monitor", MT_WHIRLWIND_BOX,  SPR_TVWW},
	{"elemental shield monitor",  MT_ELEMENTAL_BOX,  SPR_TVEL},
	{"pasta box",                 MT_EGGMAN_BOX,     SPR_TVEG},
})
	itemlib.addItem({
		name = item[1],
		tip = item[2] == MT_EGGMAN_BOX and "Finally some nutritive food!" or "A monitor",

		mobjsprite = item[3],
		mobjtype = item[2],
	})
end