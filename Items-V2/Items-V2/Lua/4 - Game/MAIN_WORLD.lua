--// FOR SCIENCE! YAY! //--
--// VARIABLES
-- Links
local IV2 = itemslibV2;

local IV2C = IV2.Core;
local IV2CT = IV2C.Terminal;
local IV2E = IV2.Environment;
local IV2ET = IV2E.Textures;
local IV2I = IV2.Inputs;

--// HOOKS
addHook("PlayerThink", function(player)
	if (player.mo and player.mo.valid)
		-- Floor Checking --
		if (IV2E.IsObjectOnSolidGround(player.mo))
			-- Find Grass
			local submarine = IV2ET.GrabSectorTexture(player.mo);
			if (submarine and IV2ET.photosynthesis[submarine])
				if (IV2C.DebugMode.value) print("OH MY GOD YOU TOUCHED GRASS"); end
			else
				if (IV2C.DebugMode.value) print("OH MY GOD GO TOUCH GRASS"); end
			end

			-- Changing Floor Textures
			if (IV2I[GC_CUSTOM1].down)
				local groundtype, groundbender = IV2ET.GrabFloorType(player.mo);
				local grass = IV2ET.GrabSectorTexture(player.mo);

				if ((grass and IV2ET.photosynthesis[grass]) and groundtype)
					if (IV2C.DebugMode.value) print("CURRENTLY BENDING THE GROUND..."); end
					if (groundtype == 1) groundbender.toppic = "GFZCHEK1"; else groundbender.floorpic = "GFZCHEK1"; end
				else
					if (IV2C.DebugMode.value) print("NO GROUNDBENDING FOR YOU"); end
				end
			end
		end

		-- Water Checking --
		local waterwhite = IV2E.IsObjectWithinWater(player.mo);
		if (waterwhite)
			if (IV2I[GC_CUSTOM1].press)
				if (waterwhite == 2)
					CONS_Printf(player, "Try putting more of your body in the water next time.");
				else
					CONS_Printf(player, "You drink the water. It was refreshing.");
				end
			end
		end
	end
end)