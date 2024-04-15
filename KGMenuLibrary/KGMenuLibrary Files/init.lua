// SONIC ROBO BLAST 2
// The KGMenuLibrary
//-----------------------------------------------------------------------------
// Made by Star "Guy Who Names Scripts After Him" ManiaKG.
//-----------------------------------------------------------------------------
/// \file  init.lua
/// \brief Initializes basic KGMenuLibrary data.

// ------------------------ //
//        Error(s)
// ------------------------ //
assert(not STAR.KGMenuLibrary, "The KGMenuLibrary has already been loaded!");

if ((VERSION == 202 and SUBVERSION < 13) and not tsourdt3rd) then
	error("SRB2 v2.2.13+ or TSoURDt3rd is required for the KGMenuLibrary.", 0);
end

// ------------------------ //
//      Globalization
// ------------------------ //
if not (STAR)
	rawset(_G, "STAR", {});
end
if not (STAR.KGMenuLibrary)
	STAR.KGMenuLibrary = {};
end

// ------------------------ //
//      Load Scripts
// ------------------------ //
for _, KG_INIT in ipairs({
	"1 - KG Init/_INITD.lua",
	"1 - Pride Init/LGTV_INITD_PLAYER.lua",
	"1 - Pride Init/LGTV_CONTROLS.lua",
	
	"2 - Pride Library/LGTV_LIBRARY_CORE.lua",
	"2 - Pride Library/LGTV_LIBRARY_ENVIRONMENTS.lua",
	"2 - Pride Library/LGTV_LIBRARY_MENUS.lua",
	
	"3 - Pride Register/LGTV_REGISTER_FLAGS.lua",
	"3 - Pride Register/LGTV_REGISTER_WALLTEXTURES.lua",
	"3 - Pride Register/LGTV_REGISTER_NETVARS.lua",
	
	"4 - Pride Finale/LGTV_EARTH.lua",
	"4 - Pride Finale/LGTV_EYES.lua"
})
	dofile(KG_INIT);
end