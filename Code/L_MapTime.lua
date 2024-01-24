--// BASIC MAPTIME SYSTEM //--
--// BY STARMANIAKG //--

local maptime = 0;

addHook("MapLoad", do maptime = 0; end) -- Reset Time
addHook("ThinkFrame", do  maptime = $ + 1; end) --Add Time
addHook("PlayerThink", function(player)
	if not (player and player.valid) return; end

	-- Apply Sky on Time Change Met
	local time = {
		[450] = 4,
		[945] = 8,
		[1250] = 11,
		[1850] = 1,
	};

	local validSkies = {
		["GFS_CLD1"] = true,
		["GFS_CLD2"] = true,
		["GFS_CLD3"] = true
	};

    if (time[maptime]) then
        P_SetupLevelSky(time[maptime]);
		maptime = ($ >= 1850 and 0 or $);
    end

	-- Change all the Ceiling Textures to Correspond with the Time, and We're Done :)
    for sector in sectors.iterate() do
        if not (maptime >= 450) then break; end
		if not (validSkies[sector.ceilingpic]) then break; end

        sector.ceilingpic = "F_SKY1";
    end
end)