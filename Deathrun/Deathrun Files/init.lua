--// ERRORs (garry's mod reference)
assert(not DeathRun, "Deathrun was Previously Loaded!") -- Already Loaded
if (CODEBASE == 220 and SUBVERSION < 10) then error("SRB2 v2.2.10+ is required to play Deathrun.", 0) end -- Wrong Version

--// VARIABLES
rawset(_G, "DeathRun", {}) -- yay

--// LOAD SCRIPTS
for _, files in ipairs({
	"1 - InitD/LUA_INITD",
	"1 - InitD/LUA_INITD_AXIS2D",
	
	"2 - Functions/LUA_XORG",
	
	"3 - Game/GLOBAL_SYSTEMD.lua",
	"3 - Game/GLOBAL_TRAPS.lua",
	"3 - Game/GLOBAL_LINEDEFS.lua",
	"3 - Game/GLOBAL_RENDERING.lua",
	
	"4 - Skins/Abilities/LUA_SPEED",
	"4 - Skins/Abilities/LUA_AVOIDANCE",
	"4 - Skins/Abilities/LUA_POWER",
	
	"4 - Skins/LUA_MAIN",
})
	dofile(files)
end
