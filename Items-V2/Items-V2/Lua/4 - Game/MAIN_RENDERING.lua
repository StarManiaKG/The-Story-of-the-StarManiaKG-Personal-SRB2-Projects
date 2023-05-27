--// MENUS! SCREENS! PATCHES! TONS OF PAINFUL CODING! HOORAY! //--
--// Also, Most of This Menu Code Is Ported From A Menu Example I Made lol //--
--// VARIABLES
-- Links
local IV2 = itemslibV2;

local IV2C = IV2.Core;
local IV2CI = IV2C.Items;
local IV2M = IV2.Menu;

--// HOOKS
/*addHook("PlayerThink", function(player)
	player = consoleplayer

	if (player and player.valid) then
		-- Main Menu --
		if not (JM.active) then
			JM.active = (TOGGLEMENU and true or false);
		else
			player.mo.momx, player.mo.momy, player.mo.momz = 0, $1, $1;
			
			-- PROCESSORS --
			JM.scroll = (((CPOS > $ + 6) and $ + 1) or (($ and CPOS - 1 < $) and $ - 1) or $)
			
			-- Up Up (Page Select Screen!)
			if (UP) then JM.currentpageoptionselected = (($ < #CRP or $ > 1) and $ - 1 or #CRP) end
			
			-- Down Down (Select Your Page!)
			if (DOWN) then JM.currentpageoptionselected = ($ < #CRP and $ + 1 or 1) end
			
			-- (Tap Left/Right, Move Left/Right If Pages Exist; Else Loop and Cycle, Until Close :P)
			// Left/Right (Left)
			if (LEFT) then
				JM.currentpageoptionselected = 1
				JM.scroll = 1
				JM.currentpage = (CP > 1 and $ - 1 or #JM)
			end
			
			// Left/Right (Right)
			if (RIGHT) then
				JM.currentpageoptionselected = 1
				JM.scroll = 1
				JM.currentpage = ($ < #JM and $ + 1 or 1)
			end
			
			-- B (Closing; NO PAGES?)
			if (CLOSE) then
				JM.currentpageoptionselected = 1
				JM.scroll = 1
				JM.currentpage = (CP > 1 and $ - 1 or 1)
				JM.active = (CP > 1 and true or false)
			end
		
			-- A (Opening)
			// Running Music
			if (SELECT) then if (CPT) then J.PlayMusic(CPT, CPTNS) end end
			
			-- Start (Reset Everything; That's All Folks)
			if (TOGGLEMENU) then
				JM.currentpage = 1
				JM.currentpageoptionselected = 1
				JM.scroll = 1
				
				JM.active = false
			end
			
			-- EXTRAS --
			-- Play Sounds
			S_StartSound(player.realmo, initMenuSound(), player)
		end
	end
end)*/

-- Renderer --
hud.add(function(v, player)
	/*if not (JM.active) then return end -- Our Menu Isn't Active? We Probably Shouldn't Run Then.
	
	player = consoleplayer
	if (player and player.valid) then
		J.SyncVars() -- Sync Our Jukebox Variables, So Everything Functions Properly
		
		-- Drawing --
		-- The Main Boxes
		v.drawFill(52, 25, 215, 30+(10*#CRP), skincolors[20].ramp[12])
		v.drawFill(60, 25, 200, 30+(10*#CRP), skincolors[20].ramp[8])
		
		-- Menu Titles
		v.drawString(160, 25, P, V_ALLOWLOWERCASE|V_BLUEMAP, "center")
		
		-- Page Numbers
		v.drawString(160, 25+(10*((#CRP > 7) and #CRP or MS)), ("Page " + CP), V_ALLOWLOWERCASE|V_SNAPTOBOTTOM|V_REDMAP, "center")
		
		-- Extras --
		-- Side Graphics
		v.drawScaled(25*FRACUNIT, 38*FRACUNIT, PGS, v.cachePatch(PG), V_SNAPTOLEFT)
		
		-- Cursors
		v.draw(95, MY+CPOS*16-(MS*16), v.cachePatch("M_CURSOR"))
			
		-- Main --
		for s = MS, MS+6 do
			if not (CRP[s]) then continue end -- Make Sure We Actually Exist
			
			-- Drawing --
			-- Music Names
			v.drawString(MX, MY+((s-MS)*10), (CRP[s].trackname),
				(CRP[s].trackname == CPTNS and V_ALLOWLOWERCASE|V_YELLOWMAP or V_ALLOWLOWERCASE), -- Change Music String's Color if Selected
				(#CRP[s].trackname > 28 and "thin-center" or "center"))
		end
	end*/

	if (IV2C.currentItem and IV2CI.Grabbed) IV2CI.DisplayActions(v, player, IV2CI[IV2C.currentItem.type]); end
end, "game")