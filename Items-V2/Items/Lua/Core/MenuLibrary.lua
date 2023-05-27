-- Menu library 0.2 by LJ Sonic
-- Feel free to use this script in your own mods.
-- DO NOT MODIFY THIS SCRIPT!

// Todo (important):
// Allow changing tip style
// Allow changing keys
// Add scrolling
// Handle mouse in grid menus

// Todo:
// Handle other text sizes and other fonts
// Make all menus grid menus (don't forget vertical menus are centered)
// Improve handling of templates?


local VERSION = 2

// If several mods use that library, fix the conflict
// by using the most recent version
if menulib and menulib.version >= VERSION return end

// Create a global table
rawset(_G, "menulib", {})
local menulib = menulib

menulib.version = VERSION

// An empty line used to organise the menus
menulib.separator = {text = "", skip = true}

// Little shortcut :p
local FU = FRACUNIT

local menus = {}
menulib.menus = menus


local function getKeys(p)
	local cmd = p.cmd

	local left, right = false, false
	if cmd.sidemove < 0
		left = true
	elseif cmd.sidemove > 0
		right = true
	end

	local up, down = false, false
	if cmd.forwardmove > 0 or cmd.buttons & BT_WEAPONPREV
		up = true
	elseif cmd.forwardmove < 0 or cmd.buttons & BT_WEAPONNEXT
		down = true
	end

	return left, right, up, down
end

// Opens a player's menu
function menulib.open(p, id, mod, choice)
	local menustates = p.menu

	// If the menu wasn't open yet, open it first
	if not menustates
		p.menu = {}
		menustates = p.menu

		menustates.mod = mod

		menustates.hkeyrepeat = 1
		menustates.vkeyrepeat = 1

		menustates.prevangleturn = p.cmd.angleturn
		menustates.prevaiming = p.cmd.aiming
		menustates.prevbuttons = p.cmd.buttons

		// Remember if the strafe flag was set for when the menu is closed
		menustates.pflags = p.pflags & PF_FORCESTRAFE
		// In menus, set the strafe flag so keys are not buggy
		p.pflags = $ | PF_FORCESTRAFE

		// Remember if the player was in analog mode for when the menu is closed
		if p.pflags & PF_ANALOGMODE
			menustates.pflags = $ | PF_ANALOGMODE
			// In menus, don't use analog mode so keys are not buggy
			p.pflags = $ & ~PF_ANALOGMODE
		end

		// Remember the thrust factor for when the menu is closed
		menustates.thrustfactor = p.thrustfactor
		// Set the thrust factor to zero so the player can't move
		p.thrustfactor = 0
	end

	/*if #menustates ~= 0 and (id == nil or type(id) ~= "string")
		print('menulib.open: menu id is nil! menustate: id = "'..menustates[#menustates].id..'", choice = '..menustates[#menustates].choice)
	end*/

	local menu = menus[menustates.mod][id]

	local menustate = {}
	menustates[#menustates + 1] = menustate

	menustate.id = id
	menustate.choice = choice or menu.choice or 1

	// Put the mouse cursor in the screen center if it was disabled until now
	if menustates.mousex == nil and menu.mouse
		menustates.mousex, menustates.mousey = 160 * FU, 100 * FU
	end

	//if menus == nil print("menulib.open: menus is nil!") end
	//if menu == nil print('menulib.open: menus["'..id..'"] is nil!') end
	if menu.open // BUG: menu is nil
		menu.open(p, menustate)
	end
end

// Closes all menus for a player
// If "force" is true, the optional "close" field is never called
function menulib.close(p, force)
	local menustates = p.menu
	local menustate = menustates[#menustates]
	local menu = menus[menustates.mod][menustate.id]

	if menu.close and not force and menu.close(p, menustate, menu) return end

	// Restore the thrust factor
	p.thrustfactor = menustates.thrustfactor

	if not (menustates.pflags & PF_FORCESTRAFE)
		// Restore the strafe flag
		p.pflags = $ & ~PF_FORCESTRAFE
	end

	if menustates.pflags & PF_ANALOGMODE
		// Restore analog mode
		p.pflags = $ | PF_ANALOGMODE
	end

	// Close the menu
	p.menu = nil
end

// Closes the currently open menu for a player
function menulib.back(p)
	local m = p.menu
	if #m == 1
		menulib.close(p)
	else
		m[#m] = nil
	end
end


// Sets the table given as parameter as the list of menus for a mod
function menulib.set(mod, newmenus)
	// Set the table as the new menu list for the mod
	menus[mod] = newmenus

	// Look for the optional generic template, and separate it from the list
	local generictemplate = menus[mod].template
	menus[mod].template = nil

	// Default template if no template was provided
	local defaulttemplate = {
		leftmargin = 6,
		topmargin = 6,
		step = 6,

		background = "WOODWLL2",
		backgroundsize = 32,
		border = "XTRMCHKW",
		bordersize = 8,
		shadow = true,

		blinkselectedtext = true,

		mouse = false
	}

	// Look for missing fields in the generic template
	// and replace them with their default values
	for f, v in pairs(defaulttemplate)
		if generictemplate[f] == nil
			generictemplate[f] = v
		end
	end

	// Look for missing fields in all the menus
	// and replace them with their default values
	for _, menu in pairs(menus[mod])
		local template = menu.template

		for _, f in ipairs({
			"x",
			"y",

			"leftmargin",
			"topmargin",
			"step",

			"background",
			"backgroundsize",
			"border",
			"bordersize",
			"shadow",

			"drawbox",
			"drawelements",
			"drawcursor",
			"drawextra",

			"blinkselectedtext",

			"open",
			"close",
			"condition",
			"handleextra",

			"mouse"
		})
			if menu[f] == nil
				if template and template[f] ~= nil
					menu[f] = template[f]
				elseif generictemplate[f] ~= nil
					menu[f] = generictemplate[f]
				end
			end
		end
	end
end


local function handleVerticalMenu(p, menu, menustate)
	local m = p.menu
	local cmd = p.cmd
	local left, right, up, down = getKeys(p)
	local bt, prevbt = cmd.buttons, m.prevbuttons
	local line = menu[menustate.choice]
	local ok = false

	if menu.mouse
		// Poll the mouse moves
		local mousedx = (cmd.angleturn - m.prevangleturn) * FU / 128
		local mousedy = (cmd.aiming - m.prevaiming) * FU / 128

		// Handle mouse if it moved
		if abs(mousedx) >= FU / 2 or abs(mousedy) >= FU / 2
			// Move the cursor
			m.mousex = $ - mousedx
			if m.mousex < 0
				m.mousex = 0
			elseif m.mousex > 320 * FU
				m.mousex = 320 * FU
			end
			m.mousey = $ - mousedy
			if m.mousey < 0
				m.mousey = 0
			elseif m.mousey > 200 * FU
				m.mousey = 200 * FU
			end

			// Select the pointed element if there is one
			local x, y = m.mousex / FU, m.mousey / FU
			local w, h = menu.w, menu.h
			local step = menu.step
			local x1, y1 = 160 - w / 2, 100 - step * (#menu - 1) / 2 - 2
			local x2, y2 = x1 + w - 1, y1 + step * (#menu - 1) + 3
			if x >= x1 and x <= x2 and y >= y1 and y <= y2
				local pointedline = (y - y1) / step + 1
				if pointedline >= 1 and pointedline <= #menu
				and y <= y1 + (pointedline - 1) * step + 3
					local line = menu[pointedline]
					if menustate.choice ~= pointedline
					and (not line.skip or line.skip ~= true and not line.skip(p))
						menustate.choice = pointedline
						S_StartSound(nil, sfx_menu1, p)
					end
				end
			end
		end
	end

	// Close the menu
	if bt & BT_CUSTOM2 and not (prevbt & BT_CUSTOM2)
		menulib.close(p)

	// Back to previous menu
	elseif bt & BT_USE and not (prevbt & BT_USE)
		menulib.back(p)

	// Confirm
	elseif bt & BT_JUMP and not (prevbt & BT_JUMP)
	//or bt & BT_ATTACK and not (prevbt & BT_ATTACK)
	or bt & BT_CUSTOM1 and not (prevbt & BT_CUSTOM1)
		if line.condition and not line.condition(p)
			S_StartSound(nil, sfx_lose, p)
		else
			if type(line.ok) == "string"
				if line.ok == nil or type(line.ok) ~= "string" print("handleVerticalMenu: menu id is nil! menustate: id = \""..menustate.id.."\", choice = "..menustate.choice) end
				menulib.open(p, line.ok, 1)
			elseif type(line.ok) == "function"
				if not line.ok(p, menustate)
					S_StartSound(nil, sfx_menu1, p)
				end
			end
		end

	// Left
	elseif left
		if line.left
			if m.prevleft
				if m.hkeyrepeat == 1
					m.hkeyrepeat = 2
					ok = true
				else
					m.hkeyrepeat = $ - 1
				end
			else
				m.hkeyrepeat = 8
				ok = true
			end

			if ok and not line.left(p, menustate)
				S_StartSound(nil, sfx_menu1, p)
			end
		end

	// Right
	elseif right
		if line.right
			if m.prevright
				if m.hkeyrepeat == 1
					m.hkeyrepeat = 2
					ok = true
				else
					m.hkeyrepeat = $ - 1
				end
			else
				m.hkeyrepeat = 8
				ok = true
			end

			if ok and not line.right(p, menustate)
				S_StartSound(nil, sfx_menu1, p)
			end
		end

	// Up
	elseif up
		if m.prevup
			if m.vkeyrepeat == 1
				m.vkeyrepeat = 2
				ok = true
			else
				m.vkeyrepeat = $ - 1
			end
		else
			m.vkeyrepeat = 8
			ok = true
		end

		if ok
			repeat
				menustate.choice = $ - 1
				if menustate.choice == 0
					menustate.choice = #menu
				end
			until not menu[menustate.choice].skip or menu[menustate.choice].skip ~= true and not menu[menustate.choice].skip(p)
			S_StartSound(nil, sfx_menu1, p)
		end

	// Down
	elseif down
		if m.prevdown
			if m.vkeyrepeat == 1
				m.vkeyrepeat = 2
				ok = true
			else
				m.vkeyrepeat = $ - 1
			end
		else
			m.vkeyrepeat = 8
			ok = true
		end

		if ok
			repeat
				menustate.choice = $ + 1
				if menustate.choice > #menu
					menustate.choice = 1
				end
			until not menu[menustate.choice].skip or menu[menustate.choice].skip ~= true and not menu[menustate.choice].skip(p)
			S_StartSound(nil, sfx_menu1, p)
		end
	end

	m.prevleft, m.prevright, m.prevup, m.prevdown = left, right, up, down
	m.prevbuttons = bt
end

local function handleGridMenu(p, menu, menustate)
	local m = p.menu
	local left, right, up, down = getKeys(p)
	local bt, prevbt = p.cmd.buttons, m.prevbuttons
	local element = not menu.dynamic and menu[menustate.choice]
	local columns = menu.columns
	local ok = false

	// Close the menu
	if bt & BT_CUSTOM2 and not (prevbt & BT_CUSTOM2)
		menulib.close(p)

	// Back to previous menu
	elseif bt & BT_USE and not (prevbt & BT_USE)
		menulib.back(p)

	// Confirm
	elseif (bt & BT_JUMP and not (prevbt & BT_JUMP) /*or bt & BT_ATTACK and not (prevbt & BT_ATTACK)*/ or bt & BT_CUSTOM1 and not (prevbt & BT_CUSTOM1))
		if menu.dynamic
			if menu.choices(p, menustate) ~= 0
				if menu.ok
					menu.ok(p, menustate.choice, menustate)
				end
			end
		elseif element
			if element.condition and not element.condition(p)
				S_StartSound(nil, sfx_lose, p)
			else
				if type(element.ok) == "string"
					menulib.open(p, element.ok, 1)
				elseif type(element.ok) == "function"
					if not element.ok(p, menustate)
						S_StartSound(nil, sfx_menu1, p)
					end
				end
			end
		end

	// Left
	elseif left
		if m.prevleft
			if m.hkeyrepeat == 1
				m.hkeyrepeat = 2
				ok = true
			else
				m.hkeyrepeat = $ - 1
			end
		else
			m.hkeyrepeat = 8
			ok = true
		end

		if ok
			local choices
			if menu.dynamic
				choices = menu.choices(p, menustate)
			else
				choices = #menu
			end
			if choices ~= 0
				repeat
					menustate.choice = ($ - 1) % columns ~= 0 and $ - 1 or $ + columns - 1
				until menustate.choice <= choices
				S_StartSound(nil, sfx_menu1, p)
			end
		end

	// Right
	elseif right
		if m.prevright
			if m.hkeyrepeat == 1
				m.hkeyrepeat = 2
				ok = true
			else
				m.hkeyrepeat = $ - 1
			end
		else
			m.hkeyrepeat = 8
			ok = true
		end

		if ok
			local choices
			if menu.dynamic
				choices = menu.choices(p, menustate)
			else
				choices = #menu
			end
			if choices ~= 0
				menustate.choice = $ % columns ~= 0 and $ + 1 <= choices and $ + 1 or ($ - 1) / columns * columns + 1
				S_StartSound(nil, sfx_menu1, p)
			end
		end

	// Up
	elseif up
		if m.prevup
			if m.vkeyrepeat == 1
				m.vkeyrepeat = 2
				ok = true
			else
				m.vkeyrepeat = $ - 1
			end
		else
			m.vkeyrepeat = 8
			ok = true
		end

		if ok
			local choices
			if menu.dynamic
				choices = menu.choices(p, menustate)
			else
				choices = #menu
			end
			if choices ~= 0
				repeat
					menustate.choice = $ > columns and $ - columns or $ + (choices - 1) / columns * columns
				until menustate.choice <= choices
				S_StartSound(nil, sfx_menu1, p)
			end
		end

	// Down
	elseif down
		if m.prevdown
			if m.vkeyrepeat == 1
				m.vkeyrepeat = 2
				ok = true
			else
				m.vkeyrepeat = $ - 1
			end
		else
			m.vkeyrepeat = 8
			ok = true
		end

		if ok
			local choices
			if menu.dynamic
				choices = menu.choices(p, menustate)
			else
				choices = #menu
			end
			if choices ~= 0
				menustate.choice = $ + columns <= choices and $ + columns or $ - ($ - 1) / columns * columns
				S_StartSound(nil, sfx_menu1, p)
			end
		end
	end

	m.prevleft, m.prevright, m.prevup, m.prevdown = left, right, up, down
	m.prevbuttons = bt
end

// Should be called once per tic, for any player who has opened the menu.
// Do NOT call if the menu isn't opened yet.
function menulib.handle(p)
	local m = p.menu
	local menustate = m[#m]
	local menu = menus[m.mod][menustate.id]
	local cmd = p.cmd

	// Prevent the player from moving or looking away
	if p.thrustfactor ~= 0
		m.thrustfactor = p.thrustfactor
		p.thrustfactor = 0
	end
	if cmd.angleturn ~= m.prevangleturn and p.mo and p.mo.valid
		p.mo.angle = $ - (cmd.angleturn - m.prevangleturn) * FU
	end
	if cmd.aiming ~= m.prevaiming
		p.aiming = $ - (cmd.aiming - m.prevaiming) * FU
	end

	// Force strafe mode while menu is open
	if not (p.pflags & PF_FORCESTRAFE)
		m.pflags = $ & ~PF_FORCESTRAFE
		p.pflags = $ | PF_FORCESTRAFE
	end

	// Forbid analog mode while menu is open
	if p.pflags & PF_ANALOGMODE
		m.pflags = $ | PF_ANALOGMODE
		p.pflags = $ & ~PF_ANALOGMODE
	end

	// If the menu has a condition that isn't met, close it.
	if menu.condition and not menu.condition(p, menustate)
		menulib.back(p, menustate)
		return
	end

	if menu.layout == "grid"
		handleGridMenu(p, menu, menustate)
	else
		handleVerticalMenu(p, menu, menustate)
	end

	if menu.handleextra
		menu.handleextra(p, menustate)
	end

	if p.mo and p.mo.valid
		m.prevangleturn = p.mo.angle / FU
	else
		m.prevangleturn = cmd.angleturn
	end
	m.prevaiming = p.aiming / FU
end


// Disable all actions when the menu is opened
for _, h in ipairs({"JumpSpecial", "AbilitySpecial", "SpinSpecial", "JumpSpinSpecial"})
	addHook(h, function(p)
		if p.menu return true end
	end)
end




function menulib.menuPosition(menu)
	local x = menu.x
	if x == nil
		x = 160 - menu.w / 2
	elseif type(x) == "function"
		x = $(menu)
	end

	local y = menu.y
	if y == nil
		y = 100 - menu.h / 2
	elseif type(y) == "function"
		y = $(menu)
	end

	return x, y
end

function menulib.menuArea(menu)
	local w, h = menu.w, menu.h

	local x1, y1 = menulib.menuPosition(menu)
	local x2, y2 = x1 + w - 1, y1 + h - 1

	return x1, y1, x2, y2
end

function menulib.elementPosition(menu, i)
	local columns = menu.columns
	local x1, y1 = menulib.menuPosition(menu)

	local dx = (menu.w - 2 * menu.leftmargin) / columns
	local dy = menu.step

	local x = x1 + menu.leftmargin + ((i - 1) % columns) * dx
	local y = y1 + menu.topmargin + ((i - 1) / columns) * dy

	return x, y
end


// Fills a rectangular area with a scaled square patch
function menulib.drawBlockBox(v, x1, y1, x2, y2, size, p)
	local drawScaled = v.drawScaled
	local s = size / p.width

	for y = y1 + p.topoffset * s, y2 + p.topoffset * s, size
		for x = x1 + p.leftoffset * s, x2 + p.leftoffset * s, size
			drawScaled(x, y, s, p)
		end
	end
end
local drawBlockBox = menulib.drawBlockBox

// Draws borders around a rectangular area with a scaled square patch
function menulib.drawBlockBorders(v, x1, y1, x2, y2, size, p)
	local drawScaled = v.drawScaled
	local s = size / p.width

	for x = x1 + p.leftoffset * s, x2 - size - size + FU + p.leftoffset * s, size
		drawScaled(x, y1, s, p)
	end

	local x = x2 - size + FU
	for y = y1 + p.topoffset * s, y2 - size - size + FU + p.topoffset * s, size
		drawScaled(x, y, s, p)
	end

	local y = y2 - size + FU
	for x = x1 + size + p.leftoffset * s, x2 - size + FU + p.leftoffset * s, size
		drawScaled(x, y, s, p)
	end

	for y = y1 + size + p.topoffset * s, y2 - size + FU + p.topoffset * s, size
		drawScaled(x1, y, s, p)
	end
end
local drawBlockBorders = menulib.drawBlockBorders

function menulib.drawMenuBox(v, x1, y1, w, h, background, backgroundsize, border, bordersize, noshadow)
	local x2, y2 = x1 + w - 1, y1 + h - 1

	// Shadow
	if not noshadow
		v.drawFill(x1 - bordersize + 2, y1 - bordersize + 2, w + bordersize + bordersize, h + bordersize + bordersize, 30)
	end

	// Background
	drawBlockBox(v, x1 * FU, y1 * FU, x2 * FU, y2 * FU, backgroundsize * FU, background)

	// Borders
	drawBlockBorders(v, (x1 - bordersize) * FU, (y1 - bordersize) * FU, (x2 + bordersize) * FU, (y2 + bordersize) * FU, bordersize * FU, border)
end
local drawMenuBox = menulib.drawMenuBox


local function drawVerticalMenu(v, p, menu, choice)
	local w, h = menu.w, menu.h
	local x1, y1 = menulib.menuPosition(menu)
	local x2, y2 = x1 + w - 1, y1 + h - 1
	local dy = menu.step

	drawMenuBox(v, x1, y1, w, h, v.cachePatch(menu.background), menu.backgroundsize, v.cachePatch(menu.border), menu.bordersize, not menu.shadow)

	local y = 98 - dy * (#menu - 1) / 2
	for i, line in ipairs(menu)
		local f = V_ALLOWLOWERCASE | (choice == i and (leveltime & 8 and V_GREENMAP or V_ORANGEMAP) or line.condition and not line.condition(p) and V_GRAYMAP or 0)

		if type(line.text) == "string"
			v.drawString(160 - v.stringWidth(line.text, f, "small") / 2, y, line.text, f, "small")
		else
			local s1, s2 = line.text(p, p.menu[#p.menu])

			if s2 == nil
				v.drawString(160 - v.stringWidth(s1, f, "small") / 2, y, s1, f, "small")
			else
				v.drawString(x1 + 3, y, s1, f, "small")
				v.drawString(x2 - 2, y, s2, f, "small-right")
			end
		end

		y = $ + dy
	end

	local tip = menu[choice].tip
	if type(tip) == "function"
		tip = $(p, menustate)
	end
	if not tip return end
	local tw = v.stringWidth(tip, V_ALLOWLOWERCASE, "small")
	local bw = (tw + 9) / 8 * 4

	v.drawFill(161 - bw, 191, bw * 2, 8, 30)
	drawBlockBox(v, (160 - bw) * FU, 190 * FU, (159 + bw) * FU, 197 * FU, 8 * FU, v.cachePatch("ACZWALA"))
	v.drawString(160 - tw / 2, 192, tip, V_ALLOWLOWERCASE, "small")

	if menu.drawextra
		menu.drawextra(v, p)
	end
end

local function drawGridMenu(v, p, menu, choice)
	local f = V_ALLOWLOWERCASE | V_MONOSPACE
	local w, h = menu.w, menu.h
	local columns = menu.columns
	local x1, y1 = menulib.menuPosition(menu)
	local x2, y2 = x1 + w - 1, y1 + h - 1
	local menustate = p.menu[#p.menu]

	local choices
	if menu.dynamic
		choices = menu.choices(p, menustate)
	else
		choices = #menu
	end

	if menu.drawbox
		menu.drawbox(v, menu, p)
	else
		drawMenuBox(v, x1, y1, w, h, v.cachePatch(menu.background), menu.backgroundsize, v.cachePatch(menu.border), menu.bordersize, not menu.shadow)
	end

	if menu.drawelements
		menu.drawelements(v, menu, menustate, p)
	else
		local dx = (w - 2 * menu.leftmargin) / columns
		local dy = menu.step
		local x = x1 + menu.leftmargin
		local y = y1 + menu.topmargin
		if menu.dynamic
			for i = 1, choices
				// Change text color if selected
				local f = f
				if choice == i and menu.blinkselectedtext
					f = $ | (leveltime & 8 and V_GREENMAP or V_ORANGEMAP)
				end

				v.drawString(x, y, menu.text(p, i, menustate), f, "small")

				if i % columns ~= 0
					x = $ + dx
				else
					x = x1 + menu.leftmargin
					y = $ + dy
				end
			end
		else
			for i, element in ipairs(menu)
				local s = type(element.text) == "string" and element.text or element.text(p, menustate)

				// Change text color if selected
				local f = f
				if choice == i and menu.blinkselectedtext
					f = $ | (leveltime & 8 and V_GREENMAP or V_ORANGEMAP)
				elseif element.condition and not element.condition(p)
					f = $ | V_GRAYMAP
				end

				if type(element.text) == "string"
					v.drawString(x, y, element.text, f, "small")
				else
					local s1, s2 = element.text(p, menustate)

					//if s2 == nil
						v.drawString(x, y, s1, f, "small")
					/*else
						v.drawString(x1 + 3, y, s1, f, "small")
						v.drawString(x2 - 2, y, s2, f, "small-right")
					end*/
				end

				if i % columns ~= 0
					x = $ + dx
				else
					x = x1 + 6
					y = $ + dy
				end
			end
		end
	end

	local s = menu.tip and menu.tip(p, choice, menustate)
	if s
		local tw = v.stringWidth(s, V_ALLOWLOWERCASE, "small")
		local bw = (tw + 9) / 8 * 4

		v.drawFill(161 - bw, 191, bw * 2, 8, 30)
		drawBlockBox(v, (160 - bw) * FU, 190 * FU, (159 + bw) * FU, 197 * FU, 8 * FU, v.cachePatch("ACZWALA"))
		v.drawString(160 - tw / 2, 192, s, V_ALLOWLOWERCASE, "small")
	end

	s = menu.tip2 and menu.tip2(p, choice, menustate)
	if s
		local tw = v.stringWidth(s, V_ALLOWLOWERCASE, "small")
		local bw = (tw + 9) / 8 * 4

		v.drawFill(161 - bw, 181, bw * 2, 8, 30)
		drawBlockBox(v, (160 - bw) * FU, 180 * FU, (159 + bw) * FU, 187 * FU, 8 * FU, v.cachePatch("ACZWALA"))
		v.drawString(160 - tw / 2, 182, s, V_ALLOWLOWERCASE, "small")
	end

	if menu.drawextra
		menu.drawextra(v, p)
	end

	// Draw custom cursor if enabled
	if menu.drawcursor ~= nil and choice <= choices
		local x, y = menulib.elementPosition(menu, choice)
		menu.drawcursor(v, x, y, menu, p)
	end
end

function menulib.draw(v, p)
	local menustates = p.menu
	local menustate = menustates[#menustates]
	//assert(menustate.id ~= nil, "menu id is nil!") // !!!
	local menu = menus[menustates.mod][menustate.id]

	// !!!
	/*if menu ~= nil
		print('menu is nil! menustate: id = "'..menustate.id..'", choice = '..menustate.choice)
	end*/

	if menu.condition and not menu.condition(p, menustate) return end
	if menu.layout == "grid" // BUG: menu is nil
		drawGridMenu(v, p, menu, menustate.choice)
	else
		drawVerticalMenu(v, p, menu, menustate.choice)
	end

	if menu.mouse
		v.drawScaled(menustates.mousex, menustates.mousey, FU, v.cachePatch("CROSHAI1"))
	end
end