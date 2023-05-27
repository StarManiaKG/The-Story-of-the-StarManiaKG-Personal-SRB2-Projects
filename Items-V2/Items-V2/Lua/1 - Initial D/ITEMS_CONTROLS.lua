--// CONTROLS //--
--// VARIABLES
local IV2 = itemslibV2;

local IV2I = IV2.Inputs;

--// INPUTS
addHook("PlayerThink", function(player)
	player = consoleplayer; -- This Can All be Done Locally lol

	if (player and player.valid)
		for _, ItemsV2Controls in pairs({
			GC_JUMP,
			GC_SPIN,

			GC_FORWARD,
			GC_BACKWARD,
			GC_STRAFELEFT,
			GC_STRAFERIGHT,

			GC_CUSTOM1,
			GC_CUSTOM2,
			GC_CUSTOM3
		})

			-- Not Tapping --
			if not (input.gameControlDown(ItemsV2Controls))
				IV2I[ItemsV2Controls].tapready = true;
				IV2I[ItemsV2Controls].press, IV2I[ItemsV2Controls].down = false, $1;
			
			-- Tapping --
			elseif (IV2I[ItemsV2Controls].tapready)
				IV2I[ItemsV2Controls].press = true;
				IV2I[ItemsV2Controls].tapready = false;

			-- Reset Tapping --
			else
				IV2I[ItemsV2Controls].press = false;
				IV2I[ItemsV2Controls].down = true;
			end
		end
	end
end)