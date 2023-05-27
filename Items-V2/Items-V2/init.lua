--// ERRORs
assert(not itemslibV2, "ItemsV2 has Already Been Loaded!");												-- Loading Two ItemsV2s
if (VERSION == 202 and SUBVERSION < 10) then error("SRB2 v2.2.10+ is Required For ItemsV2.", 0); end 	-- Wrong Version

--// VARIABLES
rawset(_G, "itemslibV2", {}); -- Globalize Everything, For Science!

--// LOAD SCRIPTS
for _, items in ipairs({
	"1 - Initial D/ITEMS_INITD.lua",
	"1 - Initial D/ITEMS_CONSOLE.lua",
	"1 - Initial D/ITEMS_CONTROLS.lua",
	
	"2 - Libraries/LIBRARY_GAME.lua",
	"2 - Libraries/LIBRARY_ITEMS.lua",

	"3 - Register/REGISTER_FOOD.lua",
	
	"4 - Game/MAIN_ITEMS.lua",
	"4 - Game/MAIN_WORLD.lua",
	"4 - Game/MAIN_RENDERING.lua"
})
	dofile(items);
end