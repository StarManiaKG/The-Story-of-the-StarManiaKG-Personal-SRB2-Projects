--// VARIABLES
-- Links
local DR = DeathRun

local DRT = DeathRun.Traps

--// HOOKS
-- Register Traps --
addHook("MapLoad", function()
	for line in lines.iterate do
		if (line.special == 820) then -- A Reference to the Month and Year That SRB2 Deathrun First Released
			local index = #DRT
			
			local front = line.frontside
			local frontsec = line.frontsector
			
			table.insert(DRT, {
				viewableindex = index,
				
				name = ((front.toptexture..front.midtexture..front.bottomtexture) or ("Trap #" + viewableindex)),
				trigger = front.textureoffset
			})
		end
	end
end)