-- Water bucket


local MAX_WATER_LEVEL = 4

local function getWaterBucketName(level)
	return "water bucket ("..level.."/"..MAX_WATER_LEVEL..")"
end

itemlib.addItem({
	name = "empty bucket",
	tip = "An empty bucket",

	mobjsprite = SPR_ITEM,
	mobjframe = H,
	mobjtype = MT_ITEMS_GROUNDITEM,
	mobjscale = FRACUNIT / 2,

	action1 = {
		name = "fill",
		action = function(p)
			if itemlib.checkLiquid(p) ~= "water" return true end
			itemlib.carryItem(p, getWaterBucketName(MAX_WATER_LEVEL))
			return true
		end
	},
})

for level = 1, MAX_WATER_LEVEL
	itemlib.addItem({
		name = getWaterBucketName(level),
		tip = "A water bucket",

		mobjsprite = SPR_ITEM,
		mobjframe = I,
		mobjtype = MT_ITEMS_GROUNDITEM,
		mobjscale = FRACUNIT / 2,

		action1 = {
			name = "drink",
			action = function(p)
				if itemlib.drink(p, itemlib.cfg.thirst / 2) return true end

				if level > 1
					itemlib.carryItem(p, getWaterBucketName(level - 1))
				else
					itemlib.carryItem(p, "empty bucket")
				end

				return true
			end
		},

		action2 = {
			name = "fill",
			action = function(p)
				if itemlib.checkLiquid(p) ~= "water" return true end
				itemlib.carryItem(p, getWaterBucketName(MAX_WATER_LEVEL))
				return true
			end
		},

		action3 = {
			name = "empty",
			action = function(p)
				itemlib.carryItem(p, "empty bucket")
				return true
			end
		},
	})
end

itemlib.addCraft({
	name = "Bucket",
	resources = {{"log", 2}},
	action = function(p)
		itemlib.takeItem(p, "empty bucket")
	end
})