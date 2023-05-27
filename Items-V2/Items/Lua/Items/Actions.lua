-- Actions


itemlib.addMobjItemAction({
	name = "give to player",
	mobjtype = MT_PLAYER,
	action = function(p, mo)
		local receiver = mo.player
		if not (receiver and receiver.valid) return true end
		local id = p.items.carrieditem.itemid
		local itemname = itemlib.items[id].name

		if itemlib.takeItem(receiver, id, 1, p.name.." gives you a "..itemname..".", p.name.." tries to give you a "..itemname..", but your inventory is full.")
			CONS_Printf(p, "You try to give a "..itemname.." to "..receiver.name..", but their inventory is full.")
			return true
		end

		CONS_Printf(p, "You give "..receiver.name.." a "..itemname..".")

		itemlib.removeCarriedItem(p)
	end
})

// Growing plant
itemlib.addMobjAction({
	mobjtype = MT_GROWINGPLANT,
	action = function(p, mo)
		local seed = mo.extravalue1
		if seed == MT_BUSH
			if itemlib.cv_logrelevantitemactions.value and p ~= server
				CONS_Printf(server, p.name.." takes a bush seed.")
			end

			return itemlib.takeItem(p, "gfz_bush_seed", 1, "You destroy the bush seedling and get its seed back.")
		elseif seed == MT_GFZFLOWER1
			return itemlib.takeItem(p, "GFZ orange flower seed", 1, "You take back the flower seed.")
		elseif seed == MT_GFZFLOWER2
			return itemlib.takeItem(p, "sunflower seed", 1, "You take back the sunflower seed.")
		elseif seed == MT_BSZSHORTFLOWER_RED
			return itemlib.takeItem(p, "red flower seed", 1, "You take back the red flower seed.")
		elseif seed == MT_BSZSHORTFLOWER_PURPLE
			return itemlib.takeItem(p, "purple flower seed", 1, "You take back the purple flower seed.")
		elseif seed == MT_BSZSHORTFLOWER_BLUE
			return itemlib.takeItem(p, "blue flower seed", 1, "You take back the blue flower seed.")
		elseif seed == MT_BSZSHORTFLOWER_CYAN
			return itemlib.takeItem(p, "cyan flower seed", 1, "You take back the cyan flower seed.")
		elseif seed == MT_BSZSHORTFLOWER_YELLOW
			return itemlib.takeItem(p, "yellow flower seed", 1, "You take back the yellow flower seed.")
		elseif seed == MT_BSZSHORTFLOWER_ORANGE
			return itemlib.takeItem(p, "orange flower seed", 1, "You take back the orange flower seed.")
		else
			return true
		end
	end
})

mobjinfo[MT_GFZFLOWER3].flags = $ & ~MF_NOTHINK


// Greenflower Zone objects

itemlib.addMobjAction({
	mobjtype = MT_BERRYBUSH,
	action = function(p, mo)
		if itemlib.takeItem(p, "berry", 6, "There are 6 berries on the bush. You take them.") return true end
		P_SpawnMobj(mo.x, mo.y, mo.z, MT_BUSH)

		if itemlib.cv_logrelevantitemactions.value and p ~= server
			CONS_Printf(server, p.name.." takes berries from a bush.")
		end
	end
})

itemlib.addMobjAction({
	mobjtype = MT_BUSH,
	action = function(p, mo)
		local n = P_RandomRange(1, 2)
		if not itemlib.canTakeItems(p, {"log", "leaves", {"gfz_bush_seed", n}})
			CONS_Printf(p, "You need more room in your inventory!")
			return true
		end

		itemlib.takeItem(p, "log", 1, false, false)
		itemlib.takeItem(p, "leaves", 1, false, false)
		itemlib.takeItem(p, "gfz_bush_seed", n, false, false)
		CONS_Printf(p, "You destroy the bush and take its log, its leaves and find "..n..(n == 1 and " seed" or " seeds").." on it.")

		if itemlib.cv_logrelevantitemactions.value and p ~= server
			CONS_Printf(server, p.name.." destroys a bush.")
		end
	end
})

for mt = MT_CORAL1, MT_CORAL3
	itemlib.addMobjAction({
		mobjtype = mt,
		action = function(p, mo)
			return itemlib.takeItem(p, "coral", 1)
		end
	})
end

itemlib.addMobjAction({
	mobjtype = MT_BLUECRYSTAL,
	action = function(p, mo)
	return itemlib.takeItem(p, "blue crystal", 1)
	end
})

for mt = MT_CACTI1, MT_CACTI4
	itemlib.addMobjAction({
		mobjtype = mt,
		action = function(p, mo)
			return itemlib.takeItem(p, "cactus", 1)
		end
	})
end

for mt = MT_STALAGMITE0, MT_STALAGMITE9
	itemlib.addMobjAction({
		mobjtype = mt,
		action = function(p, mo)
			if p.items.stupid
				CONS_Printf(p, "You feel stupid now.")
			else
				CONS_Printf(p, "You attempt to take the stalagmite, but it's stuck to the ground.")
				p.items.stupid = true
			end
			return true
		end
	})
end

itemlib.addMobjAction({
	mobjtype = MT_CANDYCANE,
	action = function(p, mo)
		return itemlib.takeItem(p, "candy cane", 1)
	end
})


// Monitors

/*itemlib.addMobjAction({
	mobjtype = MT_SUPERRINGBOX,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "super ring monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_SNEAKERTV,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "super sneakers monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_INV,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "invincibility monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_PRUP,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "extra life monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_YELLOWTV,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "attraction shield monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_BLUETV,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "force shield monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_BLACKTV,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "armageddon shield monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_WHITETV,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "whirldwind shield monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_GREENTV,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "elemental shield monitor", 1)
	end
})

itemlib.addMobjAction({
	mobjtype = MT_EGGMANBOX,
	action = function(p, mo)
		return mo.state == S_MONITOREXPLOSION2 or itemlib.takeItem(p, "pasta box", 1)
	end
})*/

// Sceneries need the MF_NOTHINK flag to be
// removed in order to interact with players.
// And to be synched between the players while we are at it.

for mt = MT_CORAL1, MT_CORAL3
	mobjinfo[mt].flags = $ & ~MF_NOTHINK
end

for mt = MT_CACTI1, MT_CACTI4
	mobjinfo[mt].flags = $ & ~MF_NOTHINK
end

for mt = MT_STALAGMITE0, MT_STALAGMITE9
	mobjinfo[mt].flags = $ & ~MF_NOTHINK
end

for _, mt in ipairs({
	MT_BERRYBUSH,
	MT_BUSH,
	MT_BLUECRYSTAL,
	MT_XMASPOLE,
	MT_CANDYCANE
})
	mobjinfo[mt].flags = $ & ~MF_NOTHINK
end