--Tails' Lab Store Menu
--Original Script by Felix44, remade into the store lua by StarManiaKG (Star)

local function sayHi()
	print("hi!") --this function is only for showing how function settings works, you are free to remove it
end

--MENU FLAGS
rawset(_G, "MNF_SLIDER", 1) --makes a setting display a slider instead of a string as its value (works the same way as the "slider" parameter)
rawset(_G, "MNF_NOSAVE", 2) --a value with this flag will not be saved/loaded from the save file
rawset(_G, "MNF_SHOWVALUE", 4) --forces the setting to display it's value, since only function settings and page changer settings don't display theirs it should only be used for those (NOTE: function settings don't have any option parameter set to them by default, don't forget to include it!)
rawset(_G, "MNF_CHANGEPAGE", 8) --settings with this flag will change the page pointer, allowing to make more complex menus with more pages and stuff, selcting these settings will change the menu page to the one defined in its "value" parameter, I suggest to give these settings the MNF_NOSAVE flag too since usually the "value" of this setting wouldn't be able to change and thus wouldn't need to be saved

addHook("PlayerSpawn", function(player)
	player.menu = {}
	player.menu.pointer = 1
	player.menu.pagepointer = 1
	player.menu.pagename = "Page 1"
	player.menu.show = false
	player.menu.timer = 0
	player.menu.contents = { --you can delete these elements of the menu or use them as reference, info to make yours is below!
		[1] = {
			{value = 0, name = "Slider 1", description = "This slider has 10 different values", maxvalue = 10, slider = true},
			{value = 1, name = "Boolean 1", description = "A boolean (ON/OFF) setting"},
			{value = 0, name = "Slider 2", description = "This slider has 4 different options\n and the text is green when selected!", maxvalue = 4, slider = true, selectedvflags = V_GREENMAP},
			{value = 1, name = "Value 9", description = "This setting can have different values,\nand it can be toggled by Slider 2", maxvalue = 5, options = {"OPTION 1", "OPTION 2", "ANOTHER OPTION", "4TH OPTION", "5TH"}, toggledby = 3},
			{value = 1, name = "Say hi", description = "This setting calls a function!", func = sayHi},
			{value = 1, name = "Boolean 2", description = "A boolean (TRUE/FALSE) setting", options = {"FALSE", "TRUE"}},
			{value = 0, name = "Slider 3", description = "This slider has 100 different values", maxvalue = 100, flags = MNF_SLIDER|MNF_NOSAVE},
			{value = 1, name = "Colorized setting", description = "This setting is red! (when not selected)", flags = MNF_NOSAVE, vflags = V_REDMAP},
			{value = 2, name = "Go to page 2", description = "Go to page 2!", flags = MNF_CHANGEPAGE|MNF_NOSAVE, pagename = "Page 2!"}},
		[2] = {
			{value = 0, name = "Slider", description = "This slider in page 2 has 10 different values", maxvalue = 10, slider = true},
			{value = 1, name = "Back", description = "Go back to page 1", flags = MNF_CHANGEPAGE|MNF_NOSAVE, pagename = "Page 1"}}
		}
	io.openlocal("client/examples/store.dat", "a+"):close() --you can change "Name" to something else, change it for the line below too if you do
	local file = io.openlocal("client/examples/store.dat", "r+")
	for e = 1,#player.menu.contents
		for i = 1,#player.menu.contents[e]
			if not player.menu.contents[e][i].flags then player.menu.contents[e][i].flags = 0 end
			if not player.menu.contents[e][i].selectedvflags then player.menu.contents[e][i].selectedvflags = V_YELLOWMAP end
			if not player.menu.contents[e][i].pagename then player.menu.contents[e][i].pagename = "Page "..player.menu.contents[e][i].value end
			if player.menu.contents[e][i].func then continue end
			if not player.menu.contents[e][i].maxvalue
					player.menu.contents[e][i].maxvalue = 2
			elseif player.menu.contents[e][i].maxvalue == 1
				CONS_Printf(player, "\133ERROR IN PAGE "..e.."\nSetting "..i.."'s maxvalue is 1! Are you sure it's intentional?")
				player.menu.contents[e][i].maxvalue = 2
				CONS_Printf(player, "\133Maxvalue was set to 2.")
			elseif player.menu.contents[e][i].maxvalue < 1
				CONS_Printf(player, "\133ERROR IN PAGE "..e.."\nSetting "..i.."'s maxvalue("..player.menu.contents[e][i].maxvalue..") is too small! Are you sure it's intentional?")
				player.menu.contents[e][i].maxvalue = 2
				CONS_Printf(player, "\133Maxvalue was set to 2.")
			end
			if not player.menu.contents[e][i].options
				player.menu.contents[e][i].options = {"OFF", "ON"}
			elseif #player.menu.contents[e][i].options < player.menu.contents[e][i].maxvalue and not (player.menu.contents[e][i].slider or player.menu.contents[e][i].flags & MNF_SLIDER)
				CONS_Printf(player, "\133ERROR IN PAGE "..e.."\nSetting "..i.."'s options can't be fewer than maxvalue("..player.menu.contents[e][i].maxvalue..")!")
				for a =1,player.menu.contents[e][i].maxvalue
					if player.menu.contents[e][i].options[a] then continue end
					player.menu.contents[e][i].options[a] = "Missing!"
				end
			end
			if player.menu.contents[e][i].flags & MNF_NOSAVE then continue end
			local text = file:read("*l")
			if text
				player.menu.contents[e][i].value = tonumber(text)
			end
		end
	end
end)

--[[player.menu.contents is the main part of the menu, every key in this table will refer to a page, if you only want a single page make a single key [1],
	you can put the elements of the menu pages inside these keys, you can have as many elements as you want, but it might be best not to have more than 10 for each page
	"value" sets their value, starting from 0, set this value to the setting's default value
		use this for your checks in your Lua, an example is at the end of this Lua
	"name" is the name of the setting that will appear on the menu
	"description" is the small text that will appear on the bottom of the screen
	"toggledby" is an extra parameter for subsections, set it to the number of the setting which your subsection setting should be depending on
		do note that if the setting that controls the subsecton is off, it will make the subsection not modifiable, but it will NOT set it to false automatically, remember that when making the checks in your other Luas
	"func" is an extra parameter for function setting, these settings can't be toggled on/off, selecting them will call the given function instead
	"maxvalue" is for a setting with more than 2 options, set this parameter to the amount of options your setting can be
		do note that "value" starts from 0, so if for example you want a 3 option setting "value" will start from 0 and reach it's max at 2 (maxvalue would still have to be set to 3 though)
		if this parameter is omitted it will be set to 2 (equivalent to an ON/OFF setting)
	"options" must be a table containing the names of all the possible setting's options, this table should be as long as maxvalue (example: if maxvalue is 3 the table should contain 3 strings)
		if this parameter is omitted it will be set to {"OFF", "ON"}
	"slider" is a boolean parameter that when set to true it displays a slider instead of a string, thus "options" can be omitted
		this parameter is deprecated since MNF_SLIDER now exists, but it can still be used and it will work the same way
	"flags" is the parameter for menu flags (MNF_*), you can see them and what they do near the start of the file
	"vflags" is the parameter for video flags (V_*), you could use this for example to give the text a different color when not selected,
		this parameter accepts any video flags, but it's primarely meant for color flags (V_*MAP) and it might break with other video flags
	"selectedvflags" is a parameter that gives the specified video flags (V_*) when the setting is selected, this default to V_YELLOWMAP if omitted
		this parameter accepts any video flags, but it's primarely meant for color flags (V_*MAP) and it might break with other video flags
	"pagename" is a parameter that sets the name of the page, this defaults to "Page " + the "value" parameter if omitted
		this paramter will only work with MNF_CHANGEPAGE settings
]]

addHook("PreThinkFrame", function()
	for player in players.iterate
		local menu = player.menu
		local contents = menu.contents[player.menu.pagepointer]
		menu.timer = max($-1, 0)
		if menu.show == false or menu.timer then return end
		local cmd = player.cmd
		if cmd.forwardmove > 0
			menu.pointer = max($-1, 1)
			menu.timer = 5
			S_StartSound(player.mo, sfx_menu1, player)
		elseif cmd.forwardmove < 0
			menu.pointer = min($+1, #contents)
			menu.timer = 5
			S_StartSound(player.mo, sfx_menu1, player)
		end
		if cmd.buttons & BT_JUMP
			if contents[menu.pointer].toggledby and contents[contents[menu.pointer].toggledby].value == 0 then return end
			if contents[menu.pointer].func
				contents[menu.pointer].func()
			elseif contents[menu.pointer].flags & MNF_CHANGEPAGE
				menu.pagename = contents[menu.pointer].pagename
				menu.pagepointer = contents[menu.pointer].value
				menu.pointer = 1
			else
				contents[menu.pointer].value = ($+1)%contents[menu.pointer].maxvalue
			end
			menu.timer = 5
			S_StartSound(player.mo, sfx_menu1, player)
		end
	end
end)

addHook("PlayerThink", function(player)
	if player.menu.show
		player.powers[pw_nocontrol] = 1
		player.mo.momx = 0
		player.mo.momy = 0
		player.mo.momz = 0
	end
end)

addHook("PlayerThink", function(player)
	if G_BuildMapName(gamemap) == "MAPTL" then
		if (player.cmd.buttons & BT_CUSTOM1) then
			if not (player.menu.show) then
				player.menu.show = true
				local file = io.openlocal("client/examples/store.dat", "w")
				for e = 1,#player.menu.contents
					for i = 1,#player.menu.contents[e]
						if player.menu.contents[e][i].func or player.menu.contents[e][i].flags & MNF_NOSAVE then continue end
						file:write(player.menu.contents[e][i].value.."\n")
					end
				end
				file:close()
			end
		end
	end
end)

local mapColors = { --this changes the menu's color based on the player's, I guess you can change it if you want
	[0] = 0,
	[V_MAGENTAMAP] = 182,
	[V_YELLOWMAP] = 74,
	[V_GREENMAP] = 115,
	[V_BLUEMAP] = 159,
	[V_REDMAP] = 41,
	[V_GRAYMAP] = 20,
	[V_ORANGEMAP] = 58,
	[V_SKYMAP] = 141,
	[V_PURPLEMAP] = 187,
	[V_AQUAMAP] = 173,
	[V_PERIDOTMAP] = 94,
	[V_AZUREMAP] = 170,
	[V_BROWNMAP] = 249,
	[V_ROSYMAP] = 203,
	[V_INVERTMAP] = 31
}

hud.add(function(v, player) --This draws the menu on the screen, you can change the values to what you prefer if you know what you are doing
	if not player.menu.show then return end
	local color = mapColors[skincolors[player.skincolor].chatcolor]
	v.drawFill(60, 25, 200, 25+(10*#player.menu.contents[player.menu.pagepointer]), color)
	v.drawString(160, 30, "SIMPLE MENU", 0, "center") --you should probably change this to something that fits for your menu though
	local pagename = player.menu.pagename
	if #player.menu.contents == 1 then pagename = "" end
	v.drawString(257, 45+(10*#player.menu.contents[player.menu.pagepointer]), pagename, 0, "small-right")
	for i = 1,#player.menu.contents[player.menu.pagepointer]
		local thecolor = player.menu.contents[player.menu.pagepointer][i].vflags or 0
		local thex = 0
		if player.menu.pointer == i then thecolor = player.menu.contents[player.menu.pagepointer][i].selectedvflags end
		if player.menu.contents[player.menu.pagepointer][i].toggledby
			thex = 10
			if player.menu.contents[player.menu.pagepointer][player.menu.contents[player.menu.pagepointer][i].toggledby].value == 0
				thecolor = $|V_TRANSLUCENT
			end
		end
		local thename = "Missing name!"
		if player.menu.contents[player.menu.pagepointer][i].name and player.menu.contents[player.menu.pagepointer][i].name ~= ""
			thename = player.menu.contents[player.menu.pagepointer][i].name
		end
		v.drawString(65+thex, 35+(10*i), thename, thecolor|V_ALLOWLOWERCASE)
		if not (player.menu.contents[player.menu.pagepointer][i].slider or player.menu.contents[player.menu.pagepointer][i].flags & MNF_SLIDER)
			local thevalue = player.menu.contents[player.menu.pagepointer][i].func and "" or player.menu.contents[player.menu.pagepointer][i].options[player.menu.contents[player.menu.pagepointer][i].value+1]
			if player.menu.contents[player.menu.pagepointer][i].flags & MNF_CHANGEPAGE then thevalue = "" end
			if player.menu.contents[player.menu.pagepointer][i].flags & MNF_SHOWVALUE then thevalue = player.menu.contents[player.menu.pagepointer][i].options[player.menu.contents[player.menu.pagepointer][i].value+1] end
			v.drawString(255, 35+(10*i), thevalue, thecolor, "right")
		elseif not player.menu.contents[player.menu.pagepointer][i].func
			local patchs = v.cachePatch("M_SLIDEL")
			local patchm = v.cachePatch("M_SLIDEM")
			local patche = v.cachePatch("M_SLIDER")
			local patchc = v.cachePatch("M_SLIDEC")
			v.draw(213, 35+(10*i), patchs)
			for e = 1,8
				v.draw(215+(4*e), 35+(10*i), patchm)
			end
			v.draw(249, 35+(10*i), patche)
			local value = player.menu.contents[player.menu.pagepointer][i].value
			local maxvalue = player.menu.contents[player.menu.pagepointer][i].maxvalue-1
			v.drawScaled(FRACUNIT*215 + 36*FixedDiv(value, maxvalue), FRACUNIT*35 + (10*i)*FRACUNIT, FRACUNIT, patchc)
		end
	end
	local patch = v.cachePatch("M_CURSOR")
	v.draw(45, 35+(10*player.menu.pointer), patch)
	local desctext = "No description found!"
	if player.menu.contents[player.menu.pagepointer][player.menu.pointer].description and player.menu.contents[player.menu.pagepointer][player.menu.pointer].description ~= ""
		desctext = player.menu.contents[player.menu.pagepointer][player.menu.pointer].description
	end
	v.drawString(60, 160, desctext, V_ALLOWLOWERCASE, "thin")
end)

--[[EXAMPLE FOR CHECKING A SETTING'S VALUE
	you have to check player.menu.contents[n1][n2].value, where n1 is the menu page, and n2 is the setting's number, this will return 1 when on and 0 when off, here's an example:
	local function myCoolFunction()
		if player.menu.contents[1][1].value
			--some cool code
		end
		return
	end
  	to check for multi-options setting's value, you do the same, do note that the value start from 0 while maxnumber "starts" from 1, so to check for the first value you check for 0, for the 2nd you check for 1 and so on
	local function myOtherFunction()
		if player.menu.contents[1][2].value < 5
			print("smol number")
		else
			print("beeg number")
		end
	end
]]