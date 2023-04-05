--// MENU EXAMPLE MADE BY STARMANIAKG#4884 (hi snoopers and future code users by the way) //--

--[[ Notes and Warnings and stuff
	While this Menu Example May Be More Lackluster than the others, this menu example will help you effeciently get what you need done, done, in a timely manner.
	It Might not be flashy, but it works, and sometimes, that's all you need.
	
	Both Regular Pages and Subpages Need some Form Of Indexes. If you don't include these, you will get warnings, errors, and things will definitely break.
	Luckily, the proper format is shown and described to you below. Aren't you lucky?
	
	Strings can only be about 26 letters long before they start to look weird. You can add your own manuvers in to replace this, using iterators and
	string.len and string.concat and things like that, but for this example, there will be none of that, because i am lazy :)
	Putting Nothing Inside of A String Is Also Very Dumb, But If you Want That, I can't stop you :P
	
	The Functions and Subpages Provided Below Can Be Utilized and Used to your Heart's Content.
	Want to Utilize both functions and menus as the same time? Great, Page 5 will serve you well.
	Only Want Functions or Subpages? Page 1 - Subpage 1 and even Page 1 - Option 3 Have You Covered
	Want to make your own custom additions to be utilized and able to be seleted?
	Add them to your custom table and make sure they're utilized and recognized under the select button's code, which is under the /* A (Select) */ Header.

	Unless you want to Implement it yourself, putting a Subpage in a Subpage DOES NOT WORK!
	...How would that work in Lua Anyway? It would probably Go On For Eternity, Right?
	
	S_StartSound() Serves No Other Purpose Than To Play Funny Sounds, and If Anyone Says Otherwise They Are Lying.
]]--

// Easily Sorted List of Easily To Remember Variable Names :)
local MM
local MMA
local MMT

local CP
local CPOS

local CSP
local CSPOS

local P
local PS

local SPE
local SPA

--// AN EASY WAY TO LOAD YOUR MENU VARS, FOR BOTH EASE OF ACCESS AND EASE OF USE! //--
local function initMenuVars(player)
	player = consoleplayer
	
	--// INITIALIZE MAIN MENU VARIABLES (which are full of repitition) //--
	MM = player.starmenu -- Initialize Menu Checking
	MMA = MM.active -- Initialize Acive Menu Checking
	MMT = MM.menutitle -- Initialize Menu Title Checking
	
	CP = MM.currentpage -- Initialize Current Page Checking
	CPOS = MM.currentpageoptionselected -- Initialize Current Page Selected Option Checking
	
	CSP = MM.currentsubpage -- Initialize Sub-Page Checking
	CSPOS = MM.currentsubpageoptionselected -- Initialize Current Sub-Page Selected Option Checking
	
	P = MM[CP] -- Initialize Real Current Page Checking
	PS = P[CPOS] -- Initialize Real Current Page and Current Option Checking
	
	SPE = PS.subpage -- Initialize Sub-Menu Checking
	SPA = MM.subpageactive -- Initialize Sub-Menu Active Checking
end

--// AN EASY WAY TO PLAY YOUR SOUNDS! //--
local function initMenuSound(player)
	player = consoleplayer
	
	-- Are We Breathing?
	if (player.starmenu and player.starmenu.active) then
		if (player.suptapping or player.sdowntapping or player.sleftapping or player.srighttapping or player.sspintapping or player.sjumptapping or player.sc1tapping) then
			--// Moving
			if (player.suptapping or player.sdowntapping or player.sleftapping or player.srighttapping) then return sfx_menu1 end
			
			--// Closing
			if (player.sspintapping) then return sfx_skid end
			
			--// Selecting
			if (player.sjumptapping) then
				-- No Submenus?
				if not (SPA) then
					if (PS.program) then return sfx_zoom end
					if (SPE) then return sfx_strpst end
				else
				-- Submenus!
					if (SPE and SPE[CSP][CSPOS]) then
						if (SPE[CSP][CSPOS].program) then return sfx_zoom end
					end
				end
			end
			
			--// *error sound effect*
			return sfx_lose
		end
	else
		--// Quitting
		if (player.sc1tapping or (player.sspintapping and not (CP > 1))) then return sfx_kc65 end
	end
	
	--// We are Literally Doing Nothing
	return
end

--[[ Variable Names, For Ease of Access and Ease of Use and All That
	MM - The Main Menu, the Starter for Everything. If this Isn't Valid, then this whole script may as well not be valid.
	MMA - Checker for if the Main Menu is active or not, it's pretty self-explanitory.
	MMT - The Main Menu's Title; Displayed Front and Center at the top of the Menu. Make sure it looks nice, neat, and pretty!
	
	CP - A Variable Pointer to the Current Page You're On; An Extremely Necessary Variable, Unless You Want Everyone to Stare at One Page Filled With Text.
	CPOS - A Variable Pointer to the Current Option Selected on the Current Page; Also Extremely Necessary, Unless You Want Nothing to be able to be Selected.
	
	CSP - A Variable Pointer to the Current Subpage You're On; A Necessary Variable, Unless You Don't Want Subpages.
	CSPOS - A Variable Pointer to the Current Option Selected on the Current Subpage;
			Necessary If you Want Subpages, Unless You Want Nothing to be able to be Selected on the Subpage.
	
	P - Checker for the Actual Current Page You're On.
		// USAGE EXAMPLE: P.pagename //
	PS - Checker for the Actual Current Page You're On and Current Option You're Selecting.
		// USAGE EXAMPLE: PS.name //
	
	SPE - Pointer to Whether Or Not There's A Subpage On the Current Page or Not;
		  Can Be Conjoined With Other Subpage Variables to Help You Find What You're Looking For.
		 // USAGE EXAMPLE: SPE[CSP][CSPOS].name //
	SPA - Checker For Whether or not There's a Subpage Active, Relatively Self Explanitory.
]]--

// Menu Functions, Each Do Random Things
local function sayHi()
	print("Hi!")
end
local function screamHi()
	print("HIIIIIIIII!")
end
local function morbiusScreech()
	print("MORBIUS!")
end
local function egg()
	print("I AM THE EGGMAN!")
end
local function lol()
	print("How Are You, Friend?")
end
local function GAMMA()
	print("GAMMA!")
end

local function speen()
	local mobj = consoleplayer.realmo
	
	if (mobj and mobj.valid) then
		mobj.rollangle = $ + ANG60
		mobj.angle = $ + ANG210
		print("CHAOS! THE GOD OF DESTRUCTION!")
	else
		print("You Aren't Real; Become Real.")
	end
end
local function randomthing()
	local mobj = consoleplayer.realmo
	
	if (mobj and mobj.valid) then
		mobj.rollangle = $ + ANG60
		mobj.angle = $ + ANG210
		P_InstaThrust(mobj, mobj.rollangle, 45*FRACUNIT)
		P_SetObjectMomZ(mobj, 35*FRACUNIT, true)
		print("CHIRP!")
	else
		print("You Aren't Real; Become Real.")
	end
end

// Actual Processor
addHook("PlayerThink", function(player)
	player = consoleplayer

	if player and player.valid then
		--// MENU CONTROLS //--
		// Buttons
		-- Select
		if not (player.cmd.buttons & BT_JUMP) then
			player.sjumptapready = true
			player.sjumptapping = false
		elseif (player.sjumptapready) then
			player.sjumptapping = true
			player.sjumptapready = false
		else
			player.sjumptapping = false
		end
		-- Backspace
		if not (player.cmd.buttons & BT_SPIN) then
			player.sspintapready = true
			player.sspintapping = false
		elseif (player.sspintapready) then
			player.sspintapping = true
			player.sspintapready = false
		else
			player.sspintapping = false
		end
		-- Start/End Menu
		if not (player.cmd.buttons & BT_CUSTOM1) then
			player.sc1tapready = true
			player.sc1tapping = false
		elseif (player.sc1tapready) then
			player.sc1tapping = true
			player.sc1tapready = false
		else
			player.sc1tapping = false
		end
		
		// Movement/Cycling
		-- Up/Down
		if not (player.cmd.forwardmove) then
			player.sverticlemoveready = true
			player.suptapping = false
			player.sdowntapping = false
		elseif (player.sverticlemoveready) then
			player.suptapping = (player.cmd.forwardmove > 0 and true or false)
			player.sdowntapping = (player.cmd.forwardmove < 0 and true or false)
			player.sverticlemoveready = false
		else
			player.suptapping = false
			player.sdowntapping = false
		end
		-- Left/Right
		if not (player.cmd.sidemove) then
			player.shortizontalmoveready = true
			player.slefttapping = false
			player.srighttapping = false
		elseif (player.shortizontalmoveready) then
			player.slefttapping = (player.cmd.sidemove < 0 and true or false)
			player.srighttapping = (player.cmd.sidemove > 0 and true or false)
			player.shortizontalmoveready = false
		else
			player.slefttapping = false
			player.srighttapping = false
		end
		
		if not (player.starmenu and player.starmenu.active) then
			--// INITIALIZE TABLE //--
			if (player.sc1tapping) then
				// One Way to Do This
				player.starmenu = {
					menutitle = "Star's Example Menu",
					
					[1] = {
						pagename = "Page 1",
						
						{
							name = "Sonic",
							
							subpage = {
								[1] = {
									pagename = "Page 1, Subpage 1",
									
									{
										name = "Knuckles - Sonic Subpage",
										program = sayHi,
									},
								},
								[2] = {
									pagename = "Page 1, Subpage 2",
									
									{
										name = "Knuckles - Sonic Subpage 2",
									},
								},
							},
						},
						{
							name = "Sonic & Tails",
							
							subpage = {
								[1] = {
									pagename = "Page 1, Subpage 1",
									
									{
										name = "Fang - Sonic Subpage 3",
									},
								},
								[2] = {
									pagename = "Page 1, Subpage 2",
									
									{
										name = "Fang - Sonic Subpage 4",
									},
								},
							},
						},
						{
							name = "Sonic, Tails & Knuckles",
							program = screamHi,
						},
					},
					[2] = {
						pagename = "Page 2",
						
						{
							name = "Tails",
							
							subpage = {
								[1] = {
									pagename = "Page 2, Subpage 1",
									
									{
										name = "Metal Sonic - Ts. Subpage 1",
									},
									{
										name = "Metal Sonic - Ts. Subpage 2",
									},
								},
								[2] = {
									pagename = "Page 2, Subpage 2",
									
									{
										name = "Amy - Tails Subpage 1",
									},
									{
										name = "Amy - Tails Subpage 2",
									},
								},
							},
						},
					},
					[3] = {
						pagename = "Page 3",
						
						{
							name = "Knuckles",
							program = morbiusScreech,
						},
					},
					[4] = {
						pagename = "Page 4",
						
						{
							name = "Eggman",
							program = egg,
						},
						{
							name = "Tikal",
							program = lol,
						},
					},
				}
				
				// Another Way To Do This
				player.starmenu[5] = {
					pagename = "Page 5",
					
					{
						name = "E-102 Gamma",
						program = GAMMA,
					},
					{
						name = "Chaos",
						program = speen,
					},
					{
						name = "Flicky",
						program = randomthing,
						
						subpage = {
							[1] = {
								pagename = "Page 5 - Subpage 1",
								
								{
									name = "Rouge",
									program = screamHi,
								},
								{
									name = "Shadow",
									program = lol,
								},
								{
									name = "Zavok",
									program = randomthing,
								},
							},
						},
					},
				}
				
				// Extra Table Variables, Usages Shown Below, Extremely Needed
				player.starmenu.active = true
				player.starmenu.subpageactive = false
				
				player.starmenu.currentpage = 1
				player.starmenu.currentsubpage = 1
				
				player.starmenu.currentpageoptionselected = 1
				player.starmenu.currentsubpageoptionselected = 1
			end
		else
			player.mo.momx, player.mo.momy, player.mo.momz = 0, $1, $1
		
			initMenuVars(player) -- initalize menu vars here
			
			--// MAIN MENU ACTORS //--
			-- Up Up --
			if (player.suptapping) then
				-- Page Select Screen! (feat. Secret Subpage Select Screen!)
				player.starmenu.currentpageoptionselected = (SPA and $ or (($ < #P or $ > 1) and $ - 1 or #P))
				player.starmenu.currentsubpageoptionselected = (SPA and (SPE and (($ < #SPE[CSP] or $ > 1) and $ - 1 or #SPE[CSP]) or 1) or 1)
			end
			
			-- Down Down --
			if (player.sdowntapping) then
				-- Select Your Page! Choose your Subpage!
				player.starmenu.currentpageoptionselected = (SPA and $ or ($ < #P and $ + 1 or 1))
				player.starmenu.currentsubpageoptionselected = (SPA and (SPE and ($ < #SPE[CSP] and $ + 1 or 1) or 1) or 1)
			end
			
			-- Left/Right (mainly left) --
			if (player.slefttapping) then
				player.starmenu.currentpageoptionselected = 1
				player.starmenu.currentsubpageoptionselected = 1
				
				-- If you Tap Left, You move Left if you have Pages or Subpages; Else You Loop and Continue the Cycle, Until you Close The Page :P
				player.starmenu.currentpage = (SPA and $ or (CP > 1 and $ - 1 or #MM))
				player.starmenu.currentsubpage = (SPA and (SPE and (CSP > 1 and $ - 1 or #SPE) or 1) or 1)
			end
			
			-- Left/Right (mainly right) --
			if (player.srighttapping) then
				player.starmenu.currentpageoptionselected = 1
				player.starmenu.currentsubpageoptionselected = 1
				
				-- If you Tap Right, You move Right if you have Pages or Subpages; Else You Loop and Continue the Cycle, Until you Close The Page :P
				-- Basically the Same Comment From Earlier: Electric Boogalo
				player.starmenu.currentpage = (SPA and $ or ($ < #MM and $ + 1 or 1))
				player.starmenu.currentsubpage = (SPA and (SPE and ($ < #SPE and $ + 1 or 1) or 1) or 1)
			end
			
			-- B (Closing) --
			if (player.sspintapping) then
				player.starmenu.currentpageoptionselected = 1
				player.starmenu.currentsubpageoptionselected = 1
				
				-- No Subpages?
				player.starmenu.currentpage = (SPA and $ or (CP > 1 and $ - 1 or 1))
				player.starmenu.active = (SPA and $ or (CP > 1 and true or false))
				
				-- Subpages!
				player.starmenu.currentsubpage = (SPA and (CSP > 1 and $ - 1 or 1) or 1)
				player.starmenu.subpageactive = (SPA and (CSP > 1 and true or false) or false)
			end
		
			-- A (Opening) --
			if (player.sjumptapping) then
				if not (SPA) then
					--// Opening Subpages
					if (SPE) then
						player.starmenu.currentsubpage = 1
						player.starmenu.currentsubpageoptionselected = 1
						player.starmenu.subpageactive = true
					end
					
					--// Running Functions
					if (PS.program) then PS.program() end
				else
					if (SPE and SPE[CSP][CSPOS]) then
						--// Running Submenu Functions
						if (SPE[CSP][CSPOS].program) then SPE[CSP][CSPOS].program() end
					end
				end
			end
			
			-- Start --
			if (player.sc1tapping) then
				-- Reset Everything; That's All Folks
				player.starmenu.currentpage = 1
				player.starmenu.currentsubpage = 1
				
				player.starmenu.currentpageoptionselected = 1
				player.starmenu.currentsubpageoptionselected = 1
				
				player.starmenu.subpageactive = false
				player.starmenu.active = false
			end
			
			--// PLAY SOUNDS
			S_StartSound(player.realmo, (initMenuSound(player) or sfx_none), player)
		end
	end
end)

// Actual Displayer
hud.add(function(v, player)
	if not (player.starmenu and player.starmenu.active) then return end
	player = consoleplayer
	
	if player and player.valid then
		initMenuVars(player) --reinitalize menu vars here, so no more errors
		
		--// RENDERER //--
		// Draw The Box
		v.drawFill(60, 25, 200, 30+(10*((SPE and SPE[CSP] and SPA) and #SPE[CSP] or #P)), 141)
		
		// Draw the Menu's Title
		v.drawString(160, 25, MMT, V_ALLOWLOWERCASE|V_BLUEMAP, "center")
		
		// Init Systemd
		for i = 1, #MM do
			for m = 1, ((SPE and SPA) and #SPE[CSP] or #P) do
				-- Make Sure These Actually Exist --
				if not (MM[i] or (P[m]) then continue end -- Main Page
				if (SPA and not SPE[CSP][m]) then continue end -- Subpage
				
				// Draw Option Names
				v.drawString(160, 30+(10*m),
					// Render All Option Names, Subpage or Not
					(((SPE and SPA) and (SPE[CSP][m].name)) or (((not SPA and P) and (P[m].name))) or ("")), -- the quotes here fix an issue for spammers
					
					// Change the Color of this Option if it's Being Selected By our Player (Now With Hacks)
					((((SPE and SPA) and ((SPE[CSP][m].name == SPE[CSP][CSPOS].name) and V_ALLOWLOWERCASE|V_YELLOWMAP)) or ((not SPA and P) and ((P[m].name == PS.name) and V_ALLOWLOWERCASE|V_YELLOWMAP))) or V_ALLOWLOWERCASE),
				"center")
				
				// Draw Page Names (For special Detail)
				v.drawString(160, 25+(10*((SPE and SPA) and #SPE[CSP] or #P)),
					// Render Page Names
					((SPE and SPA) and (SPE[CSP].pagename) or (P.pagename)),
					
					// Colorize :)
					(V_ALLOWLOWERCASE|V_SNAPTOBOTTOM|V_REDMAP),
				"center")
			end
		end
	end
end, "game")