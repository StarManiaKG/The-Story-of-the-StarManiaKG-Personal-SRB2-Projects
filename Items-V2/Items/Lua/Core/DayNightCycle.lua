-- Day and night system


function itemlib.handleTime()
	-- Update the time
	itemlib.time = ($ + itemlib.cfg.timefactor) % (86400 * TICRATE)

	-- Calculate the global light level depending on the current time of the day
	if itemlib.skylightenabled
		local t = itemlib.time
		local h = 3600 * TICRATE
		if t > 19 * h
			if t < 23 * h
				itemlib.light = itemlib.cfg.daylight - (itemlib.cfg.daylight - itemlib.cfg.nightlight) * (t - 19 * h) / ((23 - 19) * h)
			else
				itemlib.light = itemlib.cfg.nightlight
			end
		elseif t < 9 * h
			if t > 5 * h
				itemlib.light = itemlib.cfg.nightlight + (itemlib.cfg.daylight - itemlib.cfg.nightlight) * (t - 5 * h) / ((9 - 5) * h)
			else
				itemlib.light = itemlib.cfg.nightlight
			end
		else
			itemlib.light = itemlib.cfg.daylight
		end
	end

	-- Do not update the sectors if the light level hasn't changed
	if itemlib.light == itemlib.prevlight return end

	-- Update the sky according to the global light level
	local sky = itemlib.light > 160 and mapheaderinfo[gamemap].skynum or 21
	if sky ~= globallevelskynum
		P_SetupLevelSky(sky)
	end
	-- !!!
	/*if itemlib.light <= 160
		sky = 21
	elseif itemlib.light > 224
		sky = mapheaderinfo[gamemap].skynum
	elseif t <= 10 * h
		if itemlib.light = itemlib.cfg.nightlight < 224
			sky = morningsky
		end
	elseif t >= 18 * h
		if itemlib.light = itemlib.cfg.nightlight < 224
			sky = eveningsky
		end
	else
		sky = mapheaderinfo[gamemap].skynum
	end

	if sky ~= globallevelskynum
		P_SetupLevelSky(sky)
	end*/

	-- Update the light levels of all sectors in the map according to the global light level
	local light = itemlib.light
	local sectorlights = itemlib.sectorlights
	local sectors = sectors
	/*for i = 0, #sectorlights
		local sectorlight = sectors[i].lightlevel
		sectors[i].lightlevel = sectorlights[i] * light / 255
	end*/
	for i = 0, #sectorlights
		local sectorlight = sectorlights[i]

		if sectorlight > light
			sectors[i].lightlevel = light
		else
			sectors[i].lightlevel = sectorlight
		end
	end

	-- Make all campfires in a special campfire spot lighten around them
	local spots = itemlib.campfirespots[gamemap]
	if spots
		for _, mo in pairs(itemlib.campfires)
			local spot = mo.extravalue2
			if spot ~= 0
				local firelight = mo.cusval
				if firelight ~= 0
					for _, s in ipairs(spots[spot])
						sectors[s].lightlevel = max($, firelight)
					end
				end
			end
		end
	end

	itemlib.prevlight = itemlib.light
end

function itemlib.initialiseTime()
	itemlib.skylightenabled = mapheaderinfo[gamemap].items_noskylight ~= "true" and not itemlib.desolatevalley

	--if itemlib.skylightenabled
		-- Store the normal light levels of all sectors in the map
		itemlib.sectorlights = {}
		local sectorlights = itemlib.sectorlights
		local sectors = sectors
		for i = 0, #sectors - 1
			sectorlights[i] = sectors[i].lightlevel
		end
	--end

	itemlib.light = 255
	itemlib.prevlight = itemlib.light
end