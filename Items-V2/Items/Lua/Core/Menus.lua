-- Menus

// Update to mainplayer and handitemplayer
// Split menus


local itemlib = itemlib

local menulib = menulib
local drawMenuBox = menulib.drawMenuBox


local function drawStats(v, p)
	local it = p.items
	local x1 = 215
	local y1 = 68
	local x2, y2 = x1 + 63, y1 + 31

	drawMenuBox(v, x1, y1, 64, 32, v.cachePatch("WOODWLL2"), 32, v.cachePatch("XTRMCHKW"), 8)

	local f = V_ALLOWLOWERCASE | (it.hunger <= itemlib.cfg.hunger / 8 and (leveltime & 8 and V_REDMAP or V_YELLOWMAP) or it.hunger <= itemlib.cfg.hunger / 4 and V_YELLOWMAP or 0)
	v.drawString(x1 + 3, y1 + 6, "Hunger", f, "small")
	v.drawString(x2 - 2, y1 + 6, it.hunger * 100 / itemlib.cfg.hunger.."%", f, "small-right")

	f = V_ALLOWLOWERCASE | (it.thirst <= itemlib.cfg.thirst / 8 and (leveltime & 8 and V_REDMAP or V_YELLOWMAP) or it.thirst <= itemlib.cfg.thirst / 4 and V_YELLOWMAP or 0)
	v.drawString(x1 + 3, y1 + 14, "Thirst", f, "small")
	v.drawString(x2 - 2, y1 + 14, it.thirst * 100 / itemlib.cfg.thirst.."%", f, "small-right")

	//f = V_ALLOWLOWERCASE | (it.energy <= itemlib.cfg.energy / 8 and (leveltime & 8 and V_REDMAP or V_YELLOWMAP) or it.energy <= itemlib.cfg.energy / 4 and V_YELLOWMAP or 0)
	//v.drawString(x1 + 3, y1 + 22, "Energy", f, "small")
	//v.drawString(x2 - 2, y1 + 22, it.energy * 100 / itemlib.cfg.energy.."%", f, "small-right")
end

local function itemcondition(p)
	return not (p.items.carrieditem and p.items.carrieditem.valid)
end


local HELP_PAGES = 8

local function helptitle(title)
	return {
		text = "\x85"..title,
		skip = true
	}
end

local helppages = 0

local function helppage()
	helppages = $ + 1
	local page = helppages

	local line = {
		text = "Page "..page.." of "..HELP_PAGES,
		tip = "Use the left and right keys to change the page, or spin to come back.",
	}

	if page ~= 1
		line.left = function(p)
			p.menu[#p.menu].id = "help"..page - 1
		end
	end

	if page ~= HELP_PAGES
		line.right = function(p)
			p.menu[#p.menu].id = "help"..page + 1
		end
		line.ok = function(p)
			p.menu[#p.menu].id = "help"..page + 1
		end
	end

	return line
end

local function helpline(text)
	return {
		text = function() return text, "" end,
		skip = true
	}
end

local function helplinecentered(text)
	return {
		text = text,
		skip = true
	}
end


for menuname, menu in pairs({
template = {
	step = 6,
	background = "WOODWLL2",
	backgroundsize = 32,
	border = "XTRMCHKW",
	bordersize = 8
},
mainhost = {
	w = 64, h = 64,
	step = 8,
	drawextra = drawStats,
	{
		text = "Use item",
		tip = "Use an item in your inventory",
		condition = function(p)
			return not p.items.carrieditem
		end,
		ok = "useitem"
	},
	{
		text = "Craft",
		tip = "Use your items to craft something",
		condition = function(p)
			return not p.items.carrieditem
		end,
		ok = function(p)
			if itemlib.nobuildcampfire or itemlib.desolatevalley
				menulib.open(p, "craftnocampfire")
			else
				menulib.open(p, "craft")
			end
		end
	},
	/*{
		text = "Destroy item",
		tip = "Remove an item from your inventory",
		ok = "dropitem"
	},*/
	/*{
		text = "Move item",
		tip = "Move an item from your inventory to another slot",
		ok = "moveitem"
	},*/
	menulib.separator,
	{
		text = "Options",
		tip = "Setup the options (not fully implemented)",
		ok = "options"
	},
	{
		text = "Help",
		tip = "Read the help manual",
		ok = "help1"
	}
},
mainplayer = {
	w = 64, h = 64,
	step = 8,
	drawextra = drawStats,
	{
		text = "Use item",
		tip = "Use an item in your inventory",
		condition = function(p)
			return not p.items.carrieditem
		end,
		ok = "useitem"
	},
	{
		text = "Craft",
		tip = "Use your items to craft something",
		condition = function(p)
			return not p.items.carrieditem
		end,
		ok = function(p)
			if itemlib.nobuildcampfire or itemlib.desolatevalley
				menulib.open(p, "craftnocampfire")
			else
				menulib.open(p, "craft")
			end
		end
	},
	/*{
		text = "Destroy item",
		tip = "Remove an item from your inventory",
		ok = "dropitem"
	},*/
	/*{
		text = "Move item",
		tip = "Move an item from your inventory to another slot",
		ok = "moveitem"
	},*/
	menulib.separator,
	{
		text = "Help",
		tip = "Read the help manual (not fully implemented)",
		ok = "help1"
	}
},
useitem = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 96,
	columns = 2,
	step = 16,
	leftmargin = 20,
	condition = itemcondition,
	choices = itemlib.itemnumber,
	text = itemlib.itemtext,
	tip = itemlib.itemtip,
	tip2 = itemlib.itemtip2,
	drawextra = itemlib.itemdrawextra,
	ok = function(p, choice, menustate)
		local it = p.items
		local id = it.itemid[choice]
		local iteminfo = itemlib.items[id]

		if it.carrieditem and it.carrieditem.valid
			local carrieditemid = it.carrieditem.itemid

			local data
			if itemlib.items[carrieditemid].stack // Stackable
				data = 1 // Quantity
			else
				data = it.carrieditem.itemquantity[choice] // Custom data
			end
			if itemlib.takeItem(p, carrieditemid, data, false) return end

			itemlib.removeCarriedItem(p)
		end

		local data
		if not iteminfo.stack
			data = it.itemquantity[choice]
		end

		itemlib.dropItem(p, id, data)

		itemlib.carryItem(p, id, data)
		if itemlib.items[id].stack // Stackable
			it.multiplecarrieditems = true
		end

		menulib.close(p)
	end
},
dropitem = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 96,
	columns = 2,
	step = 16,
	leftmargin = 20,
	condition = itemcondition,
	choices = itemlib.itemnumber,
	text = itemlib.itemtext,
	tip = itemlib.itemtip,
	tip2 = itemlib.itemtip2,
	drawextra = itemlib.itemdrawextra,
	ok = function(p, choice, menustate)
		local id = p.items.itemid[choice]

		local data
		if not itemlib.items[id].stack
			data = p.items.itemquantity[choice]
		end

		itemlib.dropItem(p, id, data)
	end
},
moveitem = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 96,
	columns = 2,
	step = 16,
	leftmargin = 20,
	condition = itemcondition,
	choices = itemlib.itemnumber,
	text = itemlib.itemtext,
	tip = itemlib.itemtip,
	tip2 = itemlib.itemtip2,
	drawextra = itemlib.itemdrawextra,
	ok = function(p, choice, menustate)
		if menustate.tmp
			local it = p.items
			it.itemid[menustate.tmp], it.itemid[choice] = $2, $1
			it.itemquantity[menustate.tmp], it.itemquantity[choice] = $2, $1
			menustate.tmp = nil
		else
			menustate.tmp = choice
		end
	end
},
giveitem = {
	layout = "grid",
	dynamic = true,
	background = "ACZWALA",
	w = 256, h = 96,
	columns = 2,
	step = 16,
	leftmargin = 20,
	condition = function(p, menustate)
		local receiver = players[menustate.receiver]
		if not (receiver and receiver.valid) return false end
		local mo1, mo2 = p.mo, receiver.mo

		return mo1 and mo1.valid and mo1.health > 0
		and mo2 and mo2.valid and mo2.health > 0
		and R_PointToDist2(mo1.x, mo1.y, mo2.x, mo2.y) <= itemlib.MAX_ACTION_DIST
		and mo2.z >= mo1.z - itemlib.MAX_ACTION_HEIGHT
		and mo2.z <= mo1.z + itemlib.MAX_ACTION_HEIGHT
	end,
	choices = itemlib.itemnumber,
	text = itemlib.itemtext,
	tip = itemlib.itemtip,
	tip2 = itemlib.itemtip2,
	drawextra = itemlib.itemdrawextra,
	ok = function(p, choice, menustate)
		local receiver = players[menustate.receiver]
		local id = p.items.itemid[choice]
		local name = itemlib.items[id].name

		local data
		if itemlib.items[id].stack // Stackable
			data = 1 // Quantity
		else
			data = p.items.itemquantity[choice] // Custom data
		end

		if itemlib.takeItem(receiver, id, data, p.name.." gives you a "..name..".", p.name.." tries to give you a "..name..", but your inventory is full.")
			CONS_Printf(p, "You try to give a "..name.." to "..receiver.name..", but their inventory is full.")
			return
		end

		CONS_Printf(p, "You give "..receiver.name.." a "..name..".")

		itemlib.dropItem(p, id, data)
	end
},
options = {
	w = 128, h = 64,
	{
		text = function()
			local s = itemlib.cfg.hunger == 60 * TICRATE and " minute" or " minutes"
			return "Hunger time", itemlib.cfg.hunger / 60 / TICRATE..s
		end,
		tip = "Time before the player starves",
		left = function()
			itemlib.cfg.hunger = $ == 60 * TICRATE and 600 * 60 * TICRATE or $ - 60 * TICRATE
		end,
		right = function()
			itemlib.cfg.hunger = $ == 600 * 60 * TICRATE and 60 * TICRATE or $ + 60 * TICRATE
		end
	},
	{
		text = function()
			local s = itemlib.cfg.thirst == 60 * TICRATE and " minute" or " minutes"
			return "Thirst time", itemlib.cfg.thirst / 60 / TICRATE..s
		end,
		tip = "Time before the player dies of thirst",
		left = function()
			itemlib.cfg.thirst = $ == 60 * TICRATE and 600 * 60 * TICRATE or $ - 60 * TICRATE
		end,
		right = function()
			itemlib.cfg.thirst = $ == 600 * 60 * TICRATE and 60 * TICRATE or $ + 60 * TICRATE
		end
	},
	/*{
		text = function()
			return "Energy time", itemlib.cfg.energy == 60 * TICRATE and "1 minute" or itemlib.cfg.energy / 60 / TICRATE.." minutes"
		end,
		tip = "Time before the player falls asleep (unimplemented)",
		left = function()
			itemlib.cfg.energy = $ == 60 * TICRATE and 60 * 60 * TICRATE or $ - 60 * TICRATE
		end,
		right = function()
			itemlib.cfg.energy = $ == 60 * 60 * TICRATE and 60 * TICRATE or $ + 60 * TICRATE
		end
	},*/
	menulib.separator,
	{
		text = function()
			return "Time factor", itemlib.cfg.timefactor
		end,
		tip = "Speed at which night and day evolve. Default value: 90",
		left = function()
			itemlib.cfg.timefactor = $ ~= 1 and $ - 1 or 600
		end,
		right = function()
			itemlib.cfg.timefactor = $ ~= 600 and $ + 1 or 1
		end
	},
	{
		text = function()
			return "Night light", itemlib.cfg.nightlight
		end,
		tip = "Light level during the night. Default value: 96",
		left = function()
			itemlib.cfg.nightlight = $ == 0 and 255 or $ == 255 and 248 or $ - 8
		end,
		right = function()
			itemlib.cfg.nightlight = $ == 248 and 255 or $ ~= 255 and $ + 8 or 0
		end
	},
	{
		text = function()
			return "Day light", itemlib.cfg.daylight
		end,
		tip = "Light level during the day. Default value: 255",
		left = function()
			itemlib.cfg.daylight = $ == 0 and 255 or $ == 255 and 248 or $ - 8
		end,
		right = function()
			itemlib.cfg.daylight = $ == 248 and 255 or $ ~= 255 and $ + 8 or 0
		end
	},
	menulib.separator,
	// !!!
	{
		//text = "Apply changes",
		text = "Reset",
		//tip = "Reset and apply the new options. Warning, this will also reset your inventory and anything you've done so far!", // !!!
		//tip = "Reset and apply the new options. Warning, this will reset anything you've done so far!",
		tip = "Reset all players' inventories, hunger, thirst, and other stats",
		ok = function(p)
			for p in players.iterate
				if p.menu
					menulib.close(p)
				end
				itemlib.initialisePlayer(p)
			end
			//CONS_Printf(p, "The new options have been taken in account.")
			CONS_Printf(p, "All players' stats have been reset.")
		end
	}
},
help1 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Controls"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	{text = "\x85Welcome to Srb2 Items!\x80", skip = true},
	menulib.separator,
	menulib.separator,
	helpline("This mod lets you pick and use various items in the game."),
	menulib.separator,
	helpline("To take an item you're close to, look at it and press\x84 custom action 1\x80."),
	menulib.separator,
	helpline("To open the main menu, or close any menu, press\x84 custom action 2\x80."),
	helpline("To move in the menus, use the keys you use to move your player."),
	helpline("Use \x84jump\x80 to confirm and \x84spin\x80 to cancel."),
	menulib.separator,
	helpline("When you are done reading this page, press the right key.")
},
help2 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Hunger"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("There are different categories of items. Because\x84 food\x80 is needed"),
	helpline("in order to survive, it is probably the most important of them."),
	menulib.separator,
	helpline("Your \x84hunger level\x80 can be shown in the main menu."),
	helpline("If it reaches 0% you'll die."),
	helpline("To eat a food item, go in the \x84use item\x80 menu,"),
	helpline("accessible directly from the main menu."),
	menulib.separator,
	helpline("For instance, you can eat\x84 berries\x80."),
	helpline("You can find them on some\x84 bushes in Greenflower Zone\x80.")
},
help3 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Thirst"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("Similarly to hunger, you also need to drink in order"),
	helpline("to keep your \x84thirst level\x80 at a reasonable value."),
	menulib.separator,
	helpline("This works the same as hunger, meaning that you will die if"),
	helpline("it reaches 0% and that you can drink items using the same menu."),
	menulib.separator,
	helpline("You can get water the same way as you get other items."),
	helpline("Being in the water isn't required, although it is also possible.")
},
help4 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Giving items"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("It is also possible to \x84give\x80 some of your items to another player."),
	helpline("Look at a near player and press\x84 custom 1\x80,"),
	helpline("then choose an item to give."),
	menulib.separator,
	helpline("If the player goes away from you or leaves"),
	helpline("the server, the menu will immediately close.")
},
help5 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Destroying items"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("If you have useless items in your inventory,"),
	helpline("you may decide to\x84 destroy\x80 them."),
	helpline("This can be done from the\x84 destroy item\x80 menu."),
	helpline("Don't forget though, once you've"),
	helpline("destroyed an item, you can't get it back!")
},
help6 = {
	w = 256, h = 128,
	helppage(),
	helptitle("More (1)"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("These are the most important features,"),
	helpline("but there are many others! Here are some of them:"),
	menulib.separator,
	helpline("  \x84Night and day\x80 system"),
	menulib.separator,
	helpline("\x84  Campfires\x80, built with bush logs."),
	helpline("  Perfect for spending the night and cooking!"),
	menulib.separator,
	helpline("  \x84Seeds\x80, that you get by using flowers or bushes."),
	helpline("  Nice for farming food and wood"),
	menulib.separator,
	helpline("\x84  Chests\x80, useful for sharing items with other players")
},
help7 = {
	w = 256, h = 128,
	helppage(),
	helptitle("More (2)"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("It is possible to take \x84monitors\x80 and use them at any time."),
	menulib.separator,
	helpline("You can also take\x84 freed animals\x80 and cook them with a campfire."),
	helpline("But that wouldn't be nice, you're meant to save them!!!"),
	menulib.separator,
	helpline("...No, you can't take enemies."),
	helpline("Why does everyone ask?")
},
help8 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Credits"),
	menulib.separator,
	menulib.separator,
	helplinecentered("Director: LJ Sonic"),
	helplinecentered("Main Idea: LJ Sonic"),
	helplinecentered("Creation: LJ Sonic"),
	helplinecentered("Execution: LJ Sonic"),
	helplinecentered("Programming: LJ Sonic"),
	helplinecentered("Scripting: LJ Sonic"),
	helplinecentered("Lua Making: LJ Sonic"),
	helplinecentered("Sprite Artist: LJ Sonic"),
	helplinecentered("Testing: LJ Sonic"),
	helplinecentered("Manager: LJ Sonic"),
	helplinecentered("Managment: LJ Sonic"),
	helplinecentered("Coordinator: LJ Sonic"),
	helplinecentered("Yes, this is a troll.")
},
})
	itemlib.menus[menuname] = menu
end

menulib.set("items", itemlib.menus)