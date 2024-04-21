--// Star's Dumb Little Version Checking Script :p //--
local VERSION = 0; -- Update this as need be :p
local RUNVERSIONCHECK;

if not (myMod) then
	print("\x82myMod has not been loaded before!");
	rawset(_G, "myMod", {})
else
	print("\x82myMod has been loaded before, running version check...");
	assert(not (myMod.version > VERSION), "This version of myMod is out of date, stopping initalization!");
end
myMod.version = VERSION;
print("\x82myMod is now up to date!");