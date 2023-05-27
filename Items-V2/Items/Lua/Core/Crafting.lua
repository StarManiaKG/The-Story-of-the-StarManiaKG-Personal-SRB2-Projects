-- Crafting


itemlib.crafts = {}

function itemlib.addCraft(craft)
	itemlib.crafts[#itemlib.crafts + 1] = craft

	local first = true
	local resources = craft.resources
	for i = 1, #resources
		if type(resources[i]) == "string"
			resources[i] = {$, 1}
		end

		local resource = resources[i]
		print(resource[1], resource[2])
		resource = resource[2].." "..itemlib.itemName(resource[1], resource[2])
		if first
			first = false
			craft.resourcetext = resource
		else
			craft.resourcetext = $..", "..resource
		end
	end
end

local function enoughResources(p, items)
	for i = 1, #items
		local item = items[i]
		if itemlib.countItems(p, item[1]) < item[2] return false end
	end
	return true
end

itemlib.menus.craft = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 96,
	columns = 2,
	step = 16,
	choices = do
		return #itemlib.crafts
	end,
	text = function(p, i)
		return itemlib.crafts[i].name
	end,
	tip = function(p, i)
		return itemlib.crafts[i].resourcetext
	end,
	ok = function(p, choice)
		local craft = itemlib.crafts[choice]

		if not enoughResources(p, craft.resources)
			CONS_Printf(p, "You don't have enough resources.")
			return
		end

		if craft.action(p) return end

		for i = 1, #craft.resources
			local resource = craft.resources[i]
			itemlib.dropItem(p, resource[1], resource[2])
		end

		menulib.close(p)
	end
}