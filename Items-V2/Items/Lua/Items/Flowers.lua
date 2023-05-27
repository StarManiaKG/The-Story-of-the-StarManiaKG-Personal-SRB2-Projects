-- Flowers


itemlib.addItem({
	name = "GFZ orange flower",
	tip = "An orange flower from Greenflower",
	stack = 3,

	mobjsprite = SPR_FWR1,
	mobjtype = MT_GFZFLOWER1,

	action1 = {
		name = "destroy and get seeds",
		action = function(p)
			//CONS_Printf(p, "You look at the flower.\nIt's cute. And useless.")
			local n = P_RandomRange(1, 2)
			return itemlib.takeItem(p, "GFZ orange flower seed", n, "You destroy the flower and get "..n..(n == 1 and " seed" or " seeds").." from it.")
		end
	}
})

itemlib.addItem({
	name = "GFZ orange flower seed",
	tip = "A seed that'll grow into an orange flower",
	stack = 12,

	mobjsprite = SPR_ITEM,
	mobjframe = E,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "plant",
		action = function(p)
			return itemlib.plant(p, MT_GFZFLOWER1)
		end
	}
})

itemlib.addItem({
	name = "sunflower",
	tip = "A lively sunflower",

	mobjsprite = SPR_FWR2,
	mobjtype = MT_GFZFLOWER2,

	action1 = {
		name = "destroy and get seeds",
		action = function(p)
			//CONS_Printf(p, "You look at the sunflower.\nIt's tall. And useless.")
			local n = P_RandomRange(1, 2)
			return itemlib.takeItem(p, "sunflower seed", n, "You destroy the sunflower and get "..n..(n == 1 and " seed" or " seeds").." from it.")
		end
	}
})

/*itemlib.addMobjAction({
	mobjtype = MT_GFZFLOWER2,
	action = function(p, mo)
		return itemlib.takeItem(p, "sunflower", 1, "Despite the fact that the sunflower is taller than you, you manage to add it to your inventory.")
	end
})*/

itemlib.addItem({
	name = "sunflower seed",
	tip = "A seed that'll grow into a tall (and lively) sunflower",
	stack = 12,

	mobjsprite = SPR_ITEM,
	mobjframe = E,
	mobjtype = MT_ITEMS_GROUNDITEM,

	action1 = {
		name = "plant",
		tip = "Plant the flower seed",
		action = function(p)
			return itemlib.plant(p, MT_GFZFLOWER2)
		end
	}
})

for i, color in ipairs({"red", "purple", "blue", "cyan", "yellow", "orange"})
	itemlib.addItem({
		name = color.." flower",
		tip = "A "..color.." flower (sorry I had no idea for a good description)",
		stack = 3,

		mobjsprite = SPR_BSZ3,
		mobjframe = i - 1,
		mobjtype = _G["MT_BSZSHORTFLOWER_"..(color:upper())],

		action1 = {
			name = "destroy",
			tip = "Destroy the flower to get some seeds",
			action = function(p)
				local n = P_RandomRange(1, 2)
				return itemlib.takeItem(p, color.." flower seed", n, "You destroy the flower and get "..n..(n == 1 and " seed" or " seeds").." from it.")
			end
		}
	})

	itemlib.addItem({
		name = color.." flower seed",
		tip = "A seed that'll grow into a "..color.." flower",
		stack = 12,

		mobjsprite = SPR_ITEM,
		mobjframe = E,
		mobjtype = MT_ITEMS_GROUNDITEM,

		action1 = {
			name = "plant",
			tip = "Plant the flower seed",
			action = function(p)
				return itemlib.plant(p, _G["MT_BSZSHORTFLOWER_"..(color:upper())], SPR_BSZ4, i - 1)
			end
		}
	})
end

/*for _, color in ipairs({"red", "purple", "blue", "cyan", "yellow", "orange"})
	itemlib.addMobjAction({
		mobjtype = _G["MT_BSZSHORTFLOWER_"..(color:upper())],
		action = function(p, mo)
			return itemlib.takeItem(p, color.." flower", 1, "You pick the "..color.." flower.")
		end
	})
end*/

for mt = MT_BSZTALLFLOWER_RED, MT_BSZCLOVER
	mobjinfo[mt].flags = $ & ~MF_NOTHINK
end

itemlib.addItem({
	name = "metal flower",
	tip = "A flower made of metal",
	stack = 2,

	mobjsprite = SPR_THZP,
	mobjtype = MT_THZFLOWER1,

	action1 = {
		name = "inspect",
		action = function(p)
			CONS_Printf(p, "You inspect the metal flower.\nIt appears to be made of metal.\nIt also appears to be completely useless.")
			return true
		end
	}
})

itemlib.addItem({
	name = "withered flower",
	tip = "A lively flower. Well, not that much",
	stack = 2,

	mobjsprite = SPR_FWR4,
	mobjtype = MT_CEZFLOWER,

	action1 = {
		name = "inspect",
		action = function(p)
			CONS_Printf(p, "You look at the withered flower.\nIt doesn't seem very lively.\nYou look closer.\nIt still doesn't seem very lively.\nYou look even closer.\nIt's definitely not very lively.\nAlso it looks like it's flammable, but why would you care.")
			return true
		end
	}
})

mobjinfo[MT_CEZFLOWER].flags = $ & ~MF_NOTHINK
