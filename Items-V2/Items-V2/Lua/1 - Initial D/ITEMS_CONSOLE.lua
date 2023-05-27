--// VARIABLES
-- Links
local IV2 = itemslibV2;

local IV2C = IV2.Core;
local IV2CT = IV2C.Terminal;

--// TABLES
IV2C.DebugMode = CV_RegisterVar{
	name = "iv2debugmode",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
};