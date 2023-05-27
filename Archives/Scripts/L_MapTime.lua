local maptime = 0

addHook("MapLoad", do
	// Reset Time
	maptime = 0
end)
addHook("ThinkFrame", do
    for player in players.iterate do
		// Add Time
       	maptime = $ + 1

		// Apply Sky on Time Change Met
		local time = {
			[450] = 4,
			[945] = 8,
			[1250] = 11,
			[1850] = 1,
		}

        if (time[maptime]) then
            P_SetupLevelSky(time[maptime])
			
			maptime = (time[maptime] == 1 and 0 or $)
        end
    end
    for sector in sectors.iterate do
		// Change Sectors to Make Things Make Sense
        if (maptime >= 450 and (sector.ceilingpic == "GFS_CLD1" or sector.ceilingpic == "GFS_CLD2" or sector.ceilingpic == "GFS_CLD3")) then
            sector.ceilingpic = "F_SKY1"
        end
    end
end)
