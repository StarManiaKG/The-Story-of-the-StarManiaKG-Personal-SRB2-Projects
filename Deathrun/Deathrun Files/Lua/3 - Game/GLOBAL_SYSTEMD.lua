--// MAIN DEATHRUN MANAGER (By StarManiaKG and NARBlueBear) //--
--// WARNING: This Code is Slightly Filled With Probably Outdated and Maybe Unfunny Jokes so Read at your Own Caution //--

--// VARIABLES
-- Links
local DR = DeathRun

local DRM = DeathRun.Match
local DRN = DeathRun.Necessities

local CA = DR.MainAbility
local CA2 = DR.SideAbility
local SA = DR.SuperAbility

--// FUNCTIONS
-- Global
function DR.LoadNecessities(map)
	DR.ActualMatchStatus = "waiting"
	//local mapname = "map "..tostring(map)..": "..tostring(mapheaderinfo[map].lvlttl)
	--Actual Linedef Stuff
	if maptol == TOL_DEATHRUN then
		//if (mapheaderinfo[map].actnum) then mapname = $..tostring(mapheaderinfo[map].actnum) end
		DR.StartLinedef = (mapheaderinfo[map].DeathrunStartLinedef or 100) -- Activate that linedef to get things started!
	end
end

function DR.MatchStatus(player)
	if (DR.ActualMatchStatus == "waiting") then return end -- Has the Match Started?
		
	-- The Match Has Been Started!
	if (DR.ActualMatchStatus == "started") then
		if (player.charability) then
			if (player.charability == 2 and player.charflags & SF_MULTIABILITY) then player.charflags = $1 & ~SF_MULTIABILITY end
		end
		if (player.charability2) then
			if not (player.downwardsthokspinning and player.pflags & PF_SPINNING) then player.charability2 = CA2_NONE end
		end
		
		if ((DRM.DRM.redteamMembers and not DRM.DRM.blueteamMembers) or (DRM.DRM.blueteamMembers and not DRM.DRM.redteamMembers)) then DRM.DoMatchOver() end
	end
end

function DR.PlayerStatus(player, task)
	local string = P_RandomRange(0, 1)
	local actualstring = "This Match is in Progress! " + (string and "Don't be Like Italy!" or "Wait for this Match to Finish First.")
	
	-- Player Counting (Made by StarManiaKG and NARBluebear, Wildly Took Over a Year to Make and Rewrite) --
	if (task == 1) then
		local playercount = 0
		local dred = 0
		local dblue = 0
		
		for player in players.iterate do
			if not (player.mia) then
				playercount = $ + 1 -- Count All Players
				
				if (player.ctfteam) then
					if (player.ctfteam == 1) then -- Counts Reds
						dred = $ + 1
					else -- Counts Blues
						dblue = $ + 1
					end
				end
			end
			
			DRM.DRM.redteamMembers = dred
			DRM.DRM.blueteamMembers = dblue
		end
		
		if (DR.ActualMatchStatus == "waiting") then
			if (DRM.redteamMembers and not DRM.blueteamMembers) or (DRM.blueteamMembers and not DRM.redteamMembers) then
				if (server) then
					S_StartSound(player.mo, sfx_notadd, player)
					CONS_Printf(player, "\133You need at least one player on each team to start a Deathrun Match!")
				end
			else
				DR.ActualMatchStatus = "started"
				
				S_StartSound(player.mo, sfx_s3kad)
				P_LinedefExecute(DRN.BarrierLinedef)
				
				CONS_Printf(player, "\131Deathrun Match Started!")
			end
		end
	end
	
	-- Spectating --
	if (task == 2) then
		player = consoleplayer
		
		if (DR.ActualMatchStatus == "started") then
			CONS_Printf(player, actualstring)
			return false
		elseif (teamswitching) then
			if not (player.spectator) then
				if (DR.ActualMatchStatus == "started") then
					S_StartSound(player.realmo, sfx_fail)
					CONS_Printf(player, actualstring)
					return false
				end
			else
				if (DR.ActualMatchStatus == "started") then
					S_StartSound(player.realmo, sfx_fail)
					CONS_Printf(player, "You're dead, you can only spectate.")
					return false
				end
			end
		end
	end
end

-- Local
local function DeathRunIO(save, load)
	local player = consoleplayer
	if player and player.valid then
		local deathrun = io.openlocal("client/deathrun/deathrun.dat", "a+")
		// Creates Config File
		if not deathrun:read() then
			CONS_Printf(player, "\t\t\t\t\130No Deathrun Config Found, Creating Config File.")
			deathrun:write("sonic")
			deathrun:close()
		else
			// Now Let's Modifiy and Check our File
			if (save) then
				deathrun = io.openlocal("client/deathrun/deathrun.dat", "w+")
				deathrun:close()
				CONS_Printf(player, "\3\t\t\t\t\t\t\131Saved Deathrun Config File!")
			elseif (load) then
				deathrun:seek("set")
				deathrun:read()
				deathrun:close()
				CONS_Printf(player, "\3\t\t\t\t\t\t\t\131Deathrun Configs Loaded!")
			end
		end
	end
end
--Tables--
//Global
//DR.Sounds = {}

//// MAIN HOOKS ////
--This Hook Syncs All of the Important Variables For Everyone In-Game
addHook("NetVars", function(network)
	--Match Status Variable
	DR.ActualMatchStatus = network($)
	
	--Player Counter Variables
	playercount = network($)

	DRM.redteamMembers = network($)
	DRM.blueteamMembers = network($)
	
	--HUD Variables
end)
--These Two Hooks Set Certain Variables and Structures to their Default Values //Either on Map Change, or a Player Spawning
addHook("MapLoad", DR.LoadNecessities)
addHook("PlayerJoin", function(playernum)
	--I/O
	DeathRunIO(false, true)
	--HUD
	playernum = consoleplayer
	playernum.dot = "."
	playernum.dottime = TICRATE
end)
addHook("PlayerSpawn", function(player)
	if player.mo and player.mo.valid and maptol == TOL_DEATHRUN then
		// Main //
		player.spawned = true
		player.mia = false
		player.hasquit = false
		player.deathrundied = false
		player.warning = false
		--Run Functions
		DR.PlayerStatus(player, true)
	end
end)
--This Hook Checks if The Player Either Has a Quittime and Removes them From the Game, or Doesn't Have a Quittime and Has the Quit Variable and Adds them Back
addHook("PlayerThink", function(player)
	if (maptol == TOL_DEATHRUN) then 
		if player.mo and player.mo.valid then
			if not (player.quittime) then
				if (player.hasquit) then
					player.mia = false
					player.hasquit = false
					DR.PlayerStatus(player, true)
				end
			else
				if not (player.mia) then
					player.mia = true
					player.hasquit = true
					DR.PlayerStatus(player, true)
				end
			end
			DR.MatchStatus(player)
		elseif consoleplayer and consoleplayer.valid then
			local player = consoleplayer
			if (player.dottime != 4*TICRATE) then
				if (player.dottime <= TICRATE) then
					player.dot = "."
				elseif (player.dottime == 2*TICRATE) then
					player.dot = ".."
				elseif (player.dottime == 3*TICRATE) then
					player.dot = "..."
				end
				player.dottime = $ + 1
			else
				player.dottime = TICRATE
			end
		end
	end
end)
--This Hook Runs on The Notice of a Player Quitting, and if They Don't Already Have A Quittime, It Removes them Entirely From the Game
addHook("PlayerQuit", function(player)
	if player.mo and player.mo.valid and maptol == TOL_DEATHRUN then
		if not (player.mia) then
			player.mia = true
			DR.PlayerStatus(player, true)
		end
	end
end)
--This Hook Runs When the Player Switches Teams, and If The Player Has Already Died, It Prevents Them From Joining the Game Again
addHook("TeamSwitch", function(player, team, fromspectators)
	if player and player.valid and maptol == TOL_DEATHRUN then
		if (DR.ActualMatchStatus == "started") then
			if (fromspectators) then
				if (player.spectator and player.deathrundied) then
					DR.PlayerStatus(player, false, true)
					return false
				end
			else
				return nil
			end
		end
	end
end)
--This Hook Runs When A Player Dies, Removing them From the Game
addHook("MobjDeath", function(target)
	local player = target.player
	if player.mo and player.mo.valid and maptol == TOL_DEATHRUN then
		player.mia = true
		DR.PlayerStatus(player, true)
	end
end, MT_PLAYER)