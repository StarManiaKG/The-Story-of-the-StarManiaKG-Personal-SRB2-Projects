-- Item actions


function itemlib.addMobjAction(action)
	itemlib.mobjtypeactions[action.mobjtype] = action
end

function itemlib.addMobjItemAction(action)
	itemlib.mobjtypeitemactions[action.mobjtype] = action
end

itemlib.addMobjAction({
	mobjtype = MT_ITEMS_GROUNDITEM,
	action = function(p, mo)
		local id = itemlib.grounditemstatetoid[mo.state]
		if not id return true end

		local data
		if not itemlib.items[id].stack
			data = mo.itemdata
		end

		itemlib.carryItem(p, id, data)
	end
})

function itemlib.getAvailableActions(p)
	local item = p.items.carrieditem
	local iteminfo = itemlib.items[item.itemid]

	local actions = {}
	local mobjtypes = {}

	local mo = itemlib.findAimedMobj(p, iteminfo.mobjtypes, itemlib.mobjtypeitemactions)

	if mo and itemlib.mobjtypeitemactions[mo.type]
		actions["mobj"] = mo
	end

	for i, action in ipairs(iteminfo.actions)
		if action.mobjtypes
			if mo and action.mobjtypes[mo.type]
			and (not action.condition or action.condition(p, mo))
				actions[#actions + 1] = {i, mo}
			end
		else
			if not action.condition or action.condition(p)
				actions[#actions + 1] = {i}
			end
		end
	end

	return actions
end

function itemlib.handleActionChoice(p)
	local it = p.items
	local cmd = p.cmd
	local bt = cmd.buttons
	local n

	if it.availableactions["mobj"] and not it.availableactions["mobj"].valid
		it.availableactions["mobj"] = nil
	end

	-- Interact with mobj
	if p.cmd.sidemove < 0 and it.prevsidemove >= 0 -- Left
		local mo = it.availableactions["mobj"]
		if not mo return end
		itemlib.mobjtypeitemactions[mo.type].action(p, mo)

		it.lockeduntilnoinput = true
		it.availableactions = nil

	-- Destroy
	-- !!! Confirmation menu/less awkward key?
	/*elseif p.cmd.sidemove > 0 and it.prevsidemove <= 0 -- Right
		if iteminfo.stack and itemlib.countItems(p, it.carrieditem.itemid)
			itemlib.dropItem(p, it.carrieditem.itemid)
		else
			itemlib.removeCarriedItem(p)
		end

		if it.availableactions
			it.lockeduntilnoinput = true
			it.availableactions = nil
		end*/

	-- Store
	elseif p.cmd.forwardmove > 0 and it.prevforwardmove <= 0 -- Up
		local id = it.carrieditem.itemid
		local iteminfo = itemlib.items[id]

		if iteminfo.storable == false return end

		local data
		if iteminfo.stack -- Stackable
			data = 1 -- Quantity
		else
			data = it.carrieditem.itemdata -- Custom data
		end
		if itemlib.takeItem(p, id, data, false) return end

		itemlib.removeCarriedItem(p)

	-- Put
	elseif p.cmd.forwardmove < 0 and it.prevforwardmove >= 0 -- Down
		local id = it.carrieditem.itemid
		local iteminfo = itemlib.items[id]

		-- Put item on the ground
		if iteminfo.mobjtype
			if itemlib.putItem(p, id, it.carrieditem.itemdata)
				if it.multiplecarrieditems and itemlib.countItems(p, id)
					itemlib.dropItem(p, id)

					it.lockeduntilnoinput = true
					it.availableactions = nil
				else
					itemlib.removeCarriedItem(p)
				end
			end
		end

	elseif bt & BT_CUSTOM1 and not (it.prevbuttons & BT_CUSTOM1) -- Custom 1
		n = 1

	elseif bt & BT_CUSTOM2 and not (it.prevbuttons & BT_CUSTOM2) -- Custom 2
		n = 2

	-- More actions... maybe?
	--elseif bt & BT_JUMP and not (it.prevbuttons & BT_JUMP) -- Jump

	-- Cancel
	elseif bt & BT_USE and not (it.prevbuttons & BT_USE) -- Spin
		it.lockeduntilnoinput = true
		it.availableactions = nil

	end

	if n and it.availableactions[n]
		local id = it.carrieditem.itemid
		local iteminfo = itemlib.items[id]
		local action = iteminfo.actions[it.availableactions[n][1]]

		local removed
		if action.mobjtypes
			local mo = it.availableactions[n][2]
			-- !!! Check distance/angle?
			if mo.valid and (not action.condition or action.condition(p, mo))
				removed = not action.action(p, mo)
			end
		else
			if not action.condition or action.condition(p)
				removed = not action.action(p)
			end
		end

		-- Unless the action returns true, consume the item
		if removed
			if iteminfo.stack and itemlib.countItems(p, id)
				itemlib.dropItem(p, id)
			else
				itemlib.removeCarriedItem(p)
			end
		end

		if it.availableactions
			it.availableactions = nil
			it.lockeduntilnoinput = true
		end
	end

	if it.availableactions or it.lockeduntilnoinput
		itemlib.handleLockedPlayer(p)
	end
end

function itemlib.triggerAction(p)
	local mo = itemlib.findAimedMobj(p, itemlib.mobjtypeactions, {})
	if mo
		if not itemlib.mobjtypeactions[mo.type].action(p, mo)
			P_RemoveMobj(mo)
		end
		return
	end

	-- If no mobj has been found, check for water FOFs in front of the player
	local liquid = itemlib.checkLiquid(p)
	if liquid == "water"
		if itemlib.drink(p, itemlib.cfg.thirst / 2) return true end
		if p.items.thirst == itemlib.cfg.thirst
			CONS_Printf(p, "You drink some water.\nYou're filled with\nWATER.")
		else
			CONS_Printf(p, "You drink some water.\nThat is wet.")
		end
	elseif liquid == "goop"
		CONS_Printf(p, "It's goop, did you really think about drinking it?")
	end
	/*for _, coords in ipairs({{x, y}, {x + maxdist / FRACUNIT * cos(pmo.angle), y + maxdist / FRACUNIT * sin(pmo.angle)}})
		for ff in R_PointInSubsector(coords[1], coords[2]).sector.ffloors()
			if z1 <= ff.topheight and z2 >= ff.bottomheight and ff.flags & FF_SWIMMABLE
				local pic = ff.toppic
				if liquidflats[pic]
					local id = "water bottle"
					local n = itemlib.countItems(p, id)

					if n == itemlib.INVENTORY_SLOTS
						if P_RandomChance(FRACUNIT / 2)
							CONS_Printf(p, "No more bottles.")
						else
							CONS_Printf(p, "Your inventory is filled with water.")
						end
					elseif n == 0
						itemlib.takeItem(p, id, 1, "Fortunately you've brought a bottle with you.\nYou fill it with water.")
					elseif n == 1
						itemlib.takeItem(p, id, 1, "Luckily, you had another bottle with you.\nYou also fill it with water.")
					elseif n == 2
						itemlib.takeItem(p, id, 1, "For some reason you had a third bottle with you.\nYou fill it with water.")
					elseif n == 3
						itemlib.takeItem(p, id, 1, "You have even more bottles than you thought.\nYou fill one of them with water.")
					elseif n == 4
						itemlib.takeItem(p, id, 1, "What, do you still have bottles?!\nYou fill another of them with water.")
					elseif n == 5
						itemlib.takeItem(p, id, 1, "...\nYou fill it with water.")
					elseif n == 6
						itemlib.takeItem(p, id, 1, "You really like bottles, don't you?\nThe bottle is filled with water.")
					elseif n == 7
						itemlib.takeItem(p, id, 1, "You fill it with water.\nThe bottle, I mean.")
					else
						itemlib.takeItem(p, id, 1, "Filled.")
					end

					return
				elseif liquidflats[pic] == "goop"
					local id = "goop bottle"
					local n = itemlib.countItems(p, id)

					if n == itemlib.INVENTORY_SLOTS
						if P_RandomChance(FRACUNIT / 2)
							CONS_Printf(p, "No more bottles.")
						else
							CONS_Printf(p, "Your inventory is filled with goop.")
						end
					elseif n == 0
						itemlib.takeItem(p, id, 1, "Fortunately you've brought a bottle with you.\nYou fill it with goop.")
					elseif n == 1
						itemlib.takeItem(p, id, 1, "Luckily, you had another bottle with you.\nYou also fill it with goop.")
					elseif n == 2
						itemlib.takeItem(p, id, 1, "For some reason you had a third bottle with you.\nYou fill it with goop.")
					elseif n == 3
						itemlib.takeItem(p, id, 1, "You have even more bottles than you thought.\nYou fill one of them with goop.")
					elseif n == 4
						itemlib.takeItem(p, id, 1, "What, do you still have bottles?!\nYou fill another of them with goop.")
					elseif n == 5
						itemlib.takeItem(p, id, 1, "...\nYou fill it with goop.")
					elseif n == 6
						itemlib.takeItem(p, id, 1, "You really like bottles, don't you?\nThe bottle is filled with goop.")
					elseif n == 7
						itemlib.takeItem(p, id, 1, "You fill it with goop.\nThe bottle, I mean.")
					else
						itemlib.takeItem(p, id, 1, "Filled.")
					end

					return
				end
			end
		end
	end*/

	-- If no water FOF has been found, check the regular floor
	-- ...
end

/*local function drawHCenteredString(v, y, s, flags, align)
	local w = v.stringWidth(s, flags, align)
	v.drawString(160 - w / 2, y, s, flags, align)
end*/

local function drawActionKey(v, action, key, x, y, right)
	v.drawString(
		x, y,
		key.." \x82"..action.."\x80",
		V_ALLOWLOWERCASE,
		right and "small-right" or "small"
	)
end

function itemlib.drawActionChoice(v, p)
	local it = p.items
	local iteminfo = itemlib.items[it.carrieditem.itemid]
	local actions = iteminfo.actions
	local availableactions = it.availableactions

	-- Item-specific actions on the left side
	local y = 160
	if availableactions["mobj"] and availableactions["mobj"].valid
		local action = itemlib.mobjtypeitemactions[availableactions["mobj"].type]
		drawActionKey(v, action.name, "LEFT", 16, 160)
		y = $ - 6
	end
	if availableactions[2]
		drawActionKey(v, actions[availableactions[2][1]].name, "CUSTOM ACTION 2", 16, y)
		y = $ - 6
	end
	if availableactions[1]
		drawActionKey(v, actions[availableactions[1][1]].name, "CUSTOM ACTION 1", 16, y)
	end

	-- Generic actions on the right side
	if iteminfo.storable ~= false
		drawActionKey(v, "store in inventory", "UP", 304, 142, true)
	end
	drawActionKey(v, "put on ground", "DOWN", 304, 148, true)
	--drawActionKey(v, "destroy", "RIGHT", 304, 154, true)
	drawActionKey(v, "cancel", "SPIN", 304, 160, true)
end