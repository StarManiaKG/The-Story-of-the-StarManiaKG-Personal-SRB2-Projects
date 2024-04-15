--// ERRORS
assert(not satrb, "SATRB has already been loaded!") -- Loading Two SATRBs
if (VERSION == 202 and SUBVERSION < 10) then error("SRB2 v2.2.10+ is Required For SATRB.", 0) end -- Wrong Version

--// VARIABLES
rawset(_G, "satrb", {}) --My Boy

--// LOAD SCRIPTS
for _, files in ipairs({	
	"LUA_INITD",
	
	"Behaviors/LUA_BOSSES",
	"Behaviors/LUA_OBJECTS",

	"LUA_FLIP",
	"LUA_FOOTSTEPS",
	"LUA_LINEDEFEXES",
	"LUA_SAVING",
	"LUA_TLAB"
})
	dofile(files)
end
