--// MAIN DEATHRUN RENDERER (By StarManiaKG and NARBlueBear) //--
--// VARIABLES
-- Links
local DR = DeathRun;

local DRM = DeathRun.Match;

--NAR here again. Time to play with hud.add(). //Redone by Star :)
--First off, we are going to make a main game HUD.
for _, HUDTYPE in ipairs({"game", "intermission"}) do
	hud.add(function(v)
		-- Variables --
		-- Links
		local player = consoleplayer;
		local playerTable = {reds = {}, blues = {}, spectating = {}};
		
		if (maptol == TOL_DEATHRUN or gametype == TOL_DEATHRUN)
			-- Renders (Specific Edition) --
			-- Math --
			-- Initial Graphic (...Don't you Love Sonic the Fighters?)
			for player in players.iterate do
				for i = 0, 32 do
					if not (players[i].mo and players[i].mo.valid)
						return;
					end

					if (players[i].ctfteam == 1)
						table.insert(playerTable.reds, players[i].mo);
					elseif (players[i].ctfteam == 2)
						table.insert(playerTable.blues, players[i].mo);
					else
						table.insert(playerTable.spectating, players[i].mo);
					end
				end

				// Left Side
				v.draw(50, 50, v.cachePatch("GAMESTART"),										-- Width, Height, and Graphic
					(V_SNAPTOLEFT),																-- Flag
					(v.getColormap(playerTable.reds[0].skin, playerTable.reds[0].color)));		-- Skin
			
				// Right Side
				v.draw(-50, -50, v.cachePatch("GAMESTART"),										-- Width, Height, and Graphic
					(V_SNAPTORIGHT),															-- Flag
					(v.getColormap(playerTable.blues[0].skin, playerTable.blues[0].color)));	-- Skin
			end
			-- END OF THE SPECIFIC RENDERING --

			-- Renders For Everyone --
			-- Players
			// Counts
			v.drawString(155, 0, "Players Alive", V_YELLOWMAP|V_SNAPTORIGHT|V_PERPLAYER);
			v.drawString(160, 8, DRM.redteamMembers+" Members on the Red Team", V_REDMAP|V_SNAPTORIGHT|V_PERPLAYER);
			v.drawString(160, 16, DRM.blueteamMembers+" Members on the Blue Team", V_BLUEMAP|V_SNAPTORIGHT|V_PERPLAYER);

			// Skins
			--v.draw(30, 30, v.getSprite2Patch(player.skin, "XTRA", false, C, 0, 0), V_SNAPTORIGHT|V_SNAPTOBOTTOM, v.getColormap(player.skin, skins[player.skin].prefcolor));
			v.draw(30, 30, v.getSprite2Patch(player.skin, "LIFE", false, A, 0, 0), V_SNAPTORIGHT|V_SNAPTOBOTTOM, v.getColormap(player.skin, skins[player.skin].prefcolor));

			-- Alerts
			v.drawString(68, 80, "ALERTS", V_REDMAP|V_SNAPTOLEFT|V_PERPLAYER);
			
			if (player.ctfteam == 1)
				if (player.rwarning)
					v.drawString(68, 70,
						("RUNNERS INCOMING"),
						(V_BLUEMAP|V_SNAPTOLEFT|V_PERPLAYER));
				end
			elseif (player.ctfteam == 2)
				if (player.twarning)
					v.drawString(68, 70,
						("APPROACHING TRAPERS"),
						(V_REDMAP|V_SNAPTOLEFT|V_PERPLAYER));
				end
			else
				v.drawString(68, 70,
					("Good news! You're dead."),
					(V_REDMAP|V_SNAPTOLEFT|V_PERPLAYER));
			end
			
			-- Side HUD Properties
			v.drawString(126, 24,																						-- Width and Height
				
				(DR.ActualMatchStatus == "waiting"																		-- Start of Strings --
					and ("Waiting For Players"+player.dot)																
				or "Deathun Match Started!"),																			-- End of Strings --
				
				((DR.ActualMatchStatus == "waiting" and V_ROSYMAP or V_GREENMAP)|V_SNAPTORIGHT|V_PERPLAYER));			-- Flags
			-- END OF THE EVERYONE RENDERING --

			-- Renders For Specific Players Only --
			-- Abilities
			if (player.mo and player.mo.valid)
				if (player.charability == 1)
					v.drawString(68, 136,
						("THOK: "+(player.thokcooldown and "Ready to Use" or (G_TicsToSeconds(player.thokcooldown)+"Second Cooldown"))),
						(V_SKYMAP|V_SNAPTOLEFT|V_PERPLAYER));
				
				elseif (player.charability == 2)
					v.drawString(68, 136,
						("FLIGHT: "+player.flyhightime+" Presses Left"),
						(V_ORANGEMAP|V_SNAPTOLEFT|V_PERPLAYER));
				
				elseif (player.charability == 3)
					v.drawString(68, 136,
						(player.mo.eflags & MFE_UNDERWATER and ("SWIMMING: "+player.swimming) or ("GLIDE: "+player.gliding)),
						(V_REDMAP|V_SNAPTOLEFT|V_PERPLAYER));
				else
					v.drawString(68, 136, "NO ABILITY", V_SKYMAP|V_SNAPTOLEFT|V_PERPLAYER);
				end
			end

			-- Renders for Specific HUD Modes Only --
			-- Intermissions
			if (HUDTYPE == "intermission")
				v.drawString(120, 5,
					("The "+((DRM.redteamMembers and not DRM.blueteamMembers) and "Trappers" or "Runners")+" Win!"),
					((DRM.redteamMembers and not DRM.blueteamMembers) and V_REDMAP or V_BLUEMAP)|V_SNAPTOLEFT|V_PERPLAYER);
			end
	    end
	end, HUDTYPE) -- confused? see the top lol
end -- still confused? see the above lol