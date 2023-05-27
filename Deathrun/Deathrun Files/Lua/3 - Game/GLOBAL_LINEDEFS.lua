--Now it's time to execute some stuff through Lua //As mentioned in the HUD hook, these are the hook that sets the alerts :)
for _, LINESOFDEFS in ipairs({"RWARNING", "TWARNING"}) do
	addHook("LinedefExecute", function(line, mobj)
		if ((mobj and mobj.valid)
			and (maptol == TOL_DEATHRUN or gametype == TOL_DEATHRUN))
			
			if (LINESOFDEFS == "RWARNING")
				mobj.player.rwarning = true;
			
			elseif (LINESOFDEFS == "TWARNING")
				mobj.player.twarning = true;
			end
		end
	end, LINESOFDEFS)
end